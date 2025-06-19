#!/bin/bash
# for freebsd and derivatives
sudo pkg install -y R bwa fastqc fastp samtools bamtools
sudo Rscript -e "install.packages(c('tidyverse', 'ggplot2', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, repos = 'https://cloud.r-project.org')"
