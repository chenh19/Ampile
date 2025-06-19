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
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --set channel_priority strict

# Install into base environment
conda install -y \
  conda-forge::r-base \
  bioconda::bwa \
  bioconda::bwa-mem2 \
  bioconda::samtools \
  bioconda::fastqc \
  bioconda::fastp \
  bioconda::cutadapt \
  bioconda::bamtools
