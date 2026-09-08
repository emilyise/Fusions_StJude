#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --job-name="bam_sorting"
#SBATCH --output=logs/bam_sorting_%A_%a.out
#SBATCH --mail-user=emilyise@buffalo.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

###################################################
## SET UP ##
cd /projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/wgs_to_fusion/BAMS2

echo "loading modules" 
module load gcc/11.2.0
module load samtools/1.16.1

mkdir ../BAMS_SORTED

###################################################
## GET FILES ##
CHUNK=$1

file=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" "$CHUNK")
echo "Processing $file"

###################################################
## SORTING ##
samtools sort -n -@ 8 \
    -o "${file%.bam}.name_sorted.bam" \
    "$file" &&
    echo "sort complete"