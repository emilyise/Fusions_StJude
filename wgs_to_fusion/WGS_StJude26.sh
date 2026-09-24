#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --job-name="STJUDE_WGS"
#SBATCH --output=Fusion_StJude26.out
#SBATCH --mail-user=emilyise@buffalo.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=debug
#SBATCH --qos=debug

set -euo pipefail

###############################################################################
############ DEFINE DIRECTORIES ###############################################

# Permanent storage
P_DIR="/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/wgs_to_fusion"

# Batch sample sheet
SHEET="${P_DIR}/STJude26_wgs_sample_input.csv"

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
export JAVA_HOME=/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/easybuild/software/Core/java/25.36
export PATH=$JAVA_HOME/bin:$PATH

###############################################################################
############ LOAD MODULES #####################################################
module use /projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/easybuild/software/modules
module load Core/nextflow/26.04.6
nextflow -version

###############################################################################
############ RUN PIPELINE #####################################################

cd "$P_DIR"

echo "Sample sheet: $SHEET"
echo "Output directory: $OUTDIR"

nextflow run nf-core/sarek \
    -r 3.10.0 \
    -profile apptainer \
    --input $SHEET \
    --outdir "$OUTDIR" \
    --genome GATK.GRCh38 \
    --tools "Manta" \
    -work-dir "$P_DIR/work" \
    -c "$P_DIR/custom.config"

###############################################################################
############ OPTIONAL CLEANUP #################################################

# ONLY after successful completion + output verification
# rm -rf $P_DIR/work
