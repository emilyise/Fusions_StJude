#!/bin/bash
#SBATCH --job-name=gzip_fastq
#SBATCH --output=bigzips_%j.out
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=28
#SBATCH --mem=32G
#SBATCH --mail-user=emilyise@buffalo.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=scavenger
#SBATCH --qos=scavenger

# Load pigz for parallel gzip
module load gcccore/11.2.0
module load pigz

# Directory containing FASTQs
FASTQ_DIR=/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/wgs_to_fusion/BAMS

# Compress all uncompressed FASTQs using 28 threads total

cd "$FASTQ_DIR" || exit 1

find . -type f -name "*.fq" | \
    xargs -n 1 -P 28 pigz -f

echo "All .fq files compressed to .fq.gz files"

