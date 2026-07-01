#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --job-name="bam_to_fastq"
#SBATCH --output=logs/bam_to_fastq_%A_%a.out
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

###################################################
## SET UP ##
cd /projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/BAMS

module load gcc/11.2.0
module load bedtools

###################################################
## GET FILES ##
## GET FILES ##
CHUNK=$1

file=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" "$CHUNK")
echo "Processing $file"

###################################################
## CONVERTING ##
base=${file%.name_sorted.bam}

bedtools bamtofastq \
  -i "$file" \
  -fq "${base}.end1.fq" \
  -fq2 "${base}.end2.fq" \
&& rm "$file" \
&& echo "Converted and deleted $file" \
|| echo "Conversion failed for $file — not deleting"
