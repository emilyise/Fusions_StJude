#!/bin/bash

###############################################################################
############ IMPORTANT NOTE ############
# THIS SCRIPT WAS PRIMARILY GENERATED WITH CHATGPT (I am occasionally very lazy)

# Set directory
P_DIR="/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/wgs_to_fusion/BAMS"
cd $P_DIR

# Output CSV file
output="${P_DIR}/../STJude26_wgs_sample_input.csv"

# Write header
echo "patient,sample,lane,fastq_1,fastq_2" > "$output"

# Loop through all end1 files
for r1_file in *.WholeGenome.end1.fq.gz; do

    # Extract sample ID by removing suffix
    sample=$(basename "$r1_file" .WholeGenome.end1.fq.gz)
    IFS="_" read -r patient bar <<< "$sample"

    # Define matching R2 file
    r2_file="${sample}.WholeGenome.end2.fq.gz"

    # Check that R2 exists
    if [[ -f "$r2_file" ]]; then

        # Full paths
        r1_full="${P_DIR}/${r1_file}"
        r2_full="${P_DIR}/${r2_file}"

        # Write to CSV
        echo "${patient},${bar},lane_1,${r1_full},${r2_full}" >> "$output"

    else
        echo "Missing pair for ${sample}"
    fi
done