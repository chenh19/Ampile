#!/bin/bash

# Install Miniconda
mkdir -p ~/miniconda3
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# Initialize conda
source ~/miniconda3/bin/activate
conda init --all

# Disable auto-activation of base environment
conda config --set auto_activate_base false

# Refresh shell config
source ~/.bashrc

# Set up channels
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# Create a new environment called "ampile"
conda create -y -n ampile \
  bioconda::bwa \
  bioconda::fastqc \
  bioconda::fastp \
  bioconda::samtools \
  bioconda::bamtools

# Activate the new environment
conda activate ampile
