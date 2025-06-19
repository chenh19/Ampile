#!/bin/bash
# for institute high-performance computing cluster, typically redhat/centos/rocky linux/almalinux os

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

# Disable conda initialization when opening a shell
start0="$(grep -wn "# >>> conda initialize >>>" ~/.bashrc | head -n 1 | cut -d: -f1)"
end0="$(grep -wn "# <<< conda initialize <<<" ~/.bashrc | tail -n 1 | cut -d: -f1)"
if [[ -n "$start0" && -n "$end0" ]]; then
  sed -i "${start0},${end0}d" ~/.bashrc
fi
unset start0 end0

# Set alias for manual initialization
[ ! -f ~/.bashrc] ] && touch ~/.bashrc
if ! grep -q "alias conda-init='source ~/miniconda3/etc/profile.d/conda.sh'" ~/.bashrc ; then echo -e "alias conda-init='source ~/miniconda3/etc/profile.d/conda.sh'" >> ~/.bashrc ; fi

# Refresh shell config
source ~/.bashrc

# Set up channels
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# Create a new environment for ampile
conda create -y -n ampile conda-forge::r-base bioconda::bwa bioconda::fastqc bioconda::fastp bioconda::samtools bioconda::bamtools

# Activate environment ampile
conda activate ampile

# Install R packages
Rscript -e "install.packages(c('tidyverse', 'ggplot2', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, repos = 'https://cloud.r-project.org')"
