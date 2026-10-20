#!/bin/bash
#SBATCH --job-name=fastq_check
#SBATCH --output=fastq_check_%j.out
#SBATCH --error=fastq_check_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --mail-user=emilyise@buffalo.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

set -u

# Usage:
# sbatch validate_fastq_pairs.slurm /path/to/fastq_directory /path/to/report.csv
# This script was written primarily by AI tools 

FASTQ_DIR="${1:?Please provide the FASTQ directory}"
CSV="${2:-${FASTQ_DIR}/fastq_validation_report.csv}"

mkdir -p "$(dirname "$CSV")"

# Discover R1 files using the end1/end2 naming convention.
shopt -s nullglob
R1_FILES=(
    "$FASTQ_DIR"/*end1.fq.gz
    "$FASTQ_DIR"/*end1.fastq.gz
)

if (( ${#R1_FILES[@]} == 0 )); then
    echo "ERROR: No end1.fq.gz or end1.fastq.gz files found in $FASTQ_DIR" >&2
    exit 1
fi

# Python performs streaming validation without creating uncompressed files.
# One pair is processed at a time.
python3 - "${CSV}" "${R1_FILES[@]}" <<'PY'
import csv
import gzip
import os
import sys

csv_path = sys.argv[1]
r1_files = sys.argv[2:]

fields = [
    "sample", "R1_file", "R2_file",
    "R1_gzip", "R2_gzip",
    "R1_fastq", "R2_fastq",
    "R1_reads", "R2_reads",
    "pair_ID_check", "overall_status", "errors"
]

def sample_name(path):
    name = os.path.basename(path)
    for suffix in ("end1.fastq.gz", "end1.fq.gz"):
        if name.endswith(suffix):
            return name[:-len(suffix)]
    return name

def mate_path(path):
    if path.endswith("end1.fastq.gz"):
        return path[:-len("end1.fastq.gz")] + "end2.fastq.gz"
    return path[:-len("end1.fq.gz")] + "end2.fq.gz"

def read_record(handle, label, errors, counts):
    """Read and validate one four-line FASTQ record."""
    lines = []

    for _ in range(4):
        line = handle.readline()
        if line == "":
            break
        lines.append(line.rstrip("\r\n"))

    if not lines:
        return None

    if len(lines) != 4:
        errors.append(f"{label}: incomplete final record")
        return None

    header, sequence, separator, quality = lines
    counts[label] += 1

    if not header.startswith("@"):
        errors.append(
            f"{label}: invalid header at record {counts[label]}"
        )

    if not separator.startswith("+"):
        errors.append(
            f"{label}: invalid separator at record {counts[label]}"
        )

    if len(sequence) != len(quality):
        errors.append(
            f"{label}: sequence/quality length mismatch "
            f"at record {counts[label]}"
        )

    return header

def normalized_id(header):
    # Handles common /1 and /2 suffixes and Illumina space-separated
    # mate labels, e.g. "@READ123 1:N:0:INDEX".
    if header is None:
        return None

    identifier = header[1:].split()[0] if header[1:].split() else ""
    if identifier.endswith("/1") or identifier.endswith("/2"):
        identifier = identifier[:-2]
    return identifier

def validate_pair(r1, r2):
    errors = []
    counts = {"R1": 0, "R2": 0}
    gzip_status = {"R1": "PASS", "R2": "PASS"}
    fastq_status = {"R1": "PASS", "R2": "PASS"}
    pair_status = "PASS"

    handles = {}

    for label, path in (("R1", r1), ("R2", r2)):
        if not os.path.isfile(path):
            gzip_status[label] = "MISSING"
            fastq_status[label] = "NOT_CHECKED"
            errors.append(f"{label}: file missing: {path}")
            continue
        try:
            handles[label] = gzip.open(path, "rt", encoding="utf-8")
        except Exception as exc:
            gzip_status[label] = "FAIL"
            fastq_status[label] = "FAIL"
            errors.append(f"{label}: cannot open file: {exc}")

    # If either mate is missing or cannot be opened, validate the other
    # file independently so the report still contains useful results.
    if len(handles) != 2:
        for label, handle in handles.items():
            try:
                while read_record(handle, label, errors, counts) is not None:
                    pass
            except Exception as exc:
                gzip_status[label] = "FAIL"
                errors.append(f"{label}: decompression/read error: {exc}")
            finally:
                handle.close()

        for label in ("R1", "R2"):
            if errors and fastq_status[label] == "PASS":
                fastq_status[label] = (
                    "FAIL" if label in handles else "NOT_CHECKED"
                )

        return counts, gzip_status, fastq_status, "NOT_CHECKED", errors

    # Read corresponding records together, comparing mate identifiers.
    try:
        while True:
            h1 = read_record(handles["R1"], "R1", errors, counts)
            h2 = read_record(handles["R2"], "R2", errors, counts)

            if h1 is None and h2 is None:
                break

            if h1 is None or h2 is None:
                pair_status = "FAIL"
                errors.append("R1/R2: different read counts or incomplete record")

                # Continue through the longer file to check its structure
                # and force gzip decompression through EOF.
                label = "R2" if h1 is None else "R1"
                while read_record(handles[label], label, errors, counts) is not None:
                    pass
                break

            if normalized_id(h1) != normalized_id(h2):
                pair_status = "FAIL"
                if sum("read ID mismatch" in e for e in errors) < 10:
                    errors.append(
                        f"R1/R2: read ID mismatch at record "
                        f"{counts['R1']}: {normalized_id(h1)} != "
                        f"{normalized_id(h2)}"
                    )

    except Exception as exc:
        errors.append(f"Decompression/read error: {exc}")
        for label in ("R1", "R2"):
            gzip_status[label] = "FAIL"
            fastq_status[label] = "FAIL"

    finally:
        for handle in handles.values():
            handle.close()

    # Reaching EOF without a gzip error confirms the decompression stream
    # was readable. Structural errors are assessed independently.
    for label in ("R1", "R2"):
        if gzip_status[label] == "PASS":
            fastq_errors = [
                e for e in errors
                if e.startswith(label + ":")
            ]
            if fastq_errors:
                fastq_status[label] = "FAIL"

    if counts["R1"] != counts["R2"]:
        pair_status = "FAIL"
        if not any("different read counts" in e for e in errors):
            errors.append(
                f"Read count mismatch: R1={counts['R1']}, "
                f"R2={counts['R2']}"
            )

    return counts, gzip_status, fastq_status, pair_status, errors

with open(csv_path, "w", newline="", encoding="utf-8") as out:
    writer = csv.DictWriter(out, fieldnames=fields)
    writer.writeheader()

    for r1 in r1_files:
        r2 = mate_path(r1)
        sample = sample_name(r1)

        counts, gz, fq, pair, errors = validate_pair(r1, r2)

        all_pass = (
            gz["R1"] == "PASS" and gz["R2"] == "PASS"
            and fq["R1"] == "PASS" and fq["R2"] == "PASS"
            and pair == "PASS"
        )

        writer.writerow({
            "sample": sample,
            "R1_file": r1,
            "R2_file": r2,
            "R1_gzip": gz["R1"],
            "R2_gzip": gz["R2"],
            "R1_fastq": fq["R1"],
            "R2_fastq": fq["R2"],
            "R1_reads": counts["R1"],
            "R2_reads": counts["R2"],
            "pair_ID_check": pair,
            "overall_status": "PASS" if all_pass else "FAIL",
            "errors": "; ".join(errors)
        })

        print(
            f"{sample}: {'PASS' if all_pass else 'FAIL'} "
            f"(R1={counts['R1']}, R2={counts['R2']})",
            flush=True
        )

print(f"CSV report written to: {csv_path}")
PY
