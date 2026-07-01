#!/bin/bash

###############################################################################
############ IMPORTANT NOTE ############
# THIS SCRIPT WAS PRIMARILY GENERATED WITH CHATGPT (I am occasionally very lazy)

# Set directory
P_DIR="/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/BAMS2"
cd $P_DIR

# Output CSV file
output="${P_DIR}/STJude26_sample_input.csv"

# Write header
echo "sample,fastq_1,fastq_2,strandedness" > "$output"

# Loop through all end1 files
for r1_file in *.RNA-Seq.bam.end1.fq.gz; do

    # Extract sample ID by removing suffix
    sample=$(basename "$r1_file" .RNA-Seq.bam.end1.fq.gz)

    # Define matching R2 file
    r2_file="${sample}.RNA-Seq.bam.end2.fq.gz"

    # Check that R2 exists
    if [[ -f "$r2_file" ]]; then

        # Full paths
        r1_full="${P_DIR}/${r1_file}"
        r2_full="${P_DIR}/${r2_file}"

        # Write to CSV
        echo "${sample},${r1_full},${r2_full},reverse" >> "$output"

    else
        echo "Missing pair for ${sample}"
    fi
done