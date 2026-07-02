# Fusions - St Jude

This is my documentation of fusion analysis from St Jude cloud data. 

In this project, BAM files from St Jude are sorted, converted to fastqs, and
then run through the nf-core/rnafusion pipeline. Here's a quick outline of the flow and some of the scripts for reference. 

## BAM to fastq
1) run launch_sort to execute bam_sorting  
    -requires a .txt list of bam files as input, use ls > bam_list.txt

2) run launch_fastq to execute bam_to_fastq  
    -requires a .txt list of sorted bam files as input, use ls > bam_sorted.txt

3) zip fastq files to gz for space and for input to the nfcore pipeline with 
    big_zips

## nf-core/rnafusion pipeline
0) make sure you've properly loaded in the references, which is well documented
    by nf-core 

1) use write_sample_info.sh to create the required SAMPLE_INPUT.csv file for 
    the rnafusion pipeline 

2) run Fusion.StJude26.sh to execute fusion pipeline  
    -uses a custom config file setting slurm as executor and preventing picard 
    bam output from publishing to /results/ among other things (so if you're going to use this as a reference, make sure you understand the config file or write your own!)

3) prosper!  