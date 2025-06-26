#!/usr/bin/env bash
# Ampile pipeline

# enable exit on error
set -e

# activate conda
[ -d ~/miniconda3/envs/ampile/ ] && source ~/miniconda3/etc/profile.d/conda.sh && conda activate ampile

# initialize
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/0.initialize.sh)"

# process refseq
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/1.refseq.sh)"

# perform fastqc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/2.fastqc.sh)"

# trim and filter reads
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/3.trim.sh)"

# perform fastqc again
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/4.refastqc.sh)"

# generate bam files
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/5.bam.sh)"

# generate pileup files
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/6.mpileup.sh)"

# parse pileup files
curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/7.parse.R | Rscript -

# generate plot
curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/8.plot.R | Rscript -

# cleanup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/9.cleanup.sh)"

# deactivate conda
[ -f ~/miniconda3/etc/profile.d/conda.sh ] && conda deactivate
