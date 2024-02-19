#!/bin/bash

#SBATCH --mem-per-cpu=8G  # adjust as needed
#SBATCH -c 1 # number of threads per process
#SBATCH --output=log/environmental_sequencing/ont_trial/nanoplot_qc.out
#SBATCH --error=log/environmental_sequencing/ont_trial/nanoplot_qc.err
#SBATCH --partition=scavenger

# load dependencies
source $(conda info --base)/etc/profile.d/conda.sh
conda activate nanoplot

# make directory to store results of QC
mkdir -p analyses/environmental_sequencing/ont_trial/qc

# run nanoplot on pool 1 & 2 reads
NanoPlot --fastq analyses/reads/ont_trial/pool1_all.fastq \
 --outdir analyses/environmental_sequencing/ont_trial/qc \
 -p pool1_all_nanoplot
NanoPlot --fastq analyses/reads/ont_trial/pool2_all.fastq \
 --outdir analyses/environmental_sequencing/ont_trial/qc \
 -p pool2_all_nanoplot