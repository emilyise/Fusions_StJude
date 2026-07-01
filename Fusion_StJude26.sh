#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --job-name="STJUDE_FUSIONS"
#SBATCH --output=Fusion_StJude26.out
#SBATCH --mail-user=emilyise@buffalo.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute

set -euo pipefail

###############################################################################
############ DEFINE DIRECTORIES ###############################################

# Permanent storage
P_DIR="/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude"

# Batch sample sheet
SHEET="${P_DIR}/STJude26_sample_input.csv"

# References
R_DIR="/vscratch/grp-joyceohm/NF_RNAFusion_Refs/"

# Final output location
OUTDIR="${P_DIR}/results/"

###############################################################################
############ CREATE DIRECTORIES ###############################################

mkdir -p "$P_DIR"
mkdir -p "$P_DIR/work"
mkdir -p "$P_DIR/tmp"
mkdir -p "$P_DIR/apptainer_cache"
mkdir -p "$OUTDIR"

export NXF_APPTAINER_CACHEDIR=$P_DIR/apptainer_cache

###############################################################################
############ SET JAVA #########################################################

export JAVA_HOME=/projects/rpci/joyceohm/jdk-24.0.2
export PATH=$JAVA_HOME/bin:$PATH

###############################################################################
############ LOAD MODULES #####################################################

module load nextflow

###############################################################################
############ RUN PIPELINE #####################################################

cd "$P_DIR"

echo "Sample sheet: $SHEET"
echo "Output directory: $OUTDIR"

nextflow run nf-core/rnafusion \
    -r 4.1.0 \
    -profile apptainer \
    --tools "arriba,starfusion" \
    --input $SHEET \
    --genomes_base "$R_DIR" \
    --outdir "$OUTDIR" \
    -work-dir "$P_DIR/work" \
    -c "$P_DIR/custom.config"


###############################################################################
############ OPTIONAL CLEANUP #################################################

# ONLY after successful completion + output verification
# rm -rf $P_DIR/work

