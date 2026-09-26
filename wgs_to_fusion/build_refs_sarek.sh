#!/bin/bash
# Reference storage 
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --job-name=download_refs
#SBATCH --output=download_refs.out
#SBATCH --mail-user=emilyise@buffalo.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=scavenger
#SBATCH --qos=scavenger

# mkdir -p "$HOME/bin"
#
# ./aws/install \
#     --install-dir "$HOME/aws-cli" \
#     --bin-dir "$HOME/bin"
# 
# export PATH=$HOME/bin:$PATH
# 
# echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
# source ~/.bashrc

mkdir -p /vscratch/grp-joyceohm/NF_SAREK_Refs
R_DIR="/vscratch/grp-joyceohm/NF_SAREK_Refs"

cd "$R_DIR"

aws s3 --no-sign-request --region eu-west-1 sync s3://ngi-igenomes/igenomes/Homo_sapiens/GATK/GRCh38/ "$R_DIR/Homo_sapiens/GATK/GRCh38/"