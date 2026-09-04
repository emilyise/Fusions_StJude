#!/bin/bash

###################################################
## PATHS ##
P_DIR=/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/wgs_to_fusion
LOGDIR=$P_DIR/logs

mkdir -p "$LOGDIR"

cd "$P_DIR"

###################################################
## SPLIT BAM LIST ##
CHUNK_SIZE=10

split -l $CHUNK_SIZE bam_list.txt chunks_

echo "Created chunk files"

###################################################
## SUBMIT JOBS ##
for chunk in chunks_*; do
    n=$(wc -l < "$chunk")

    echo "Submitting $chunk ($n files)"

    sbatch \
        --array=0-$((n-1))%10 \
        --output="$LOGDIR/bam_sorting_%A_%a.out" \
        "$P_DIR/bam_sorting.sh" "$P_DIR/$chunk"
done