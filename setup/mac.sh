#!/bin/bash
# for mac
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install r bwa fastqc fastp samtools bamtools
Rscript -e "install.packages(c('dplyr', 'tidyr', 'ggplot2', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, repos = 'https://cloud.r-project.org')"
