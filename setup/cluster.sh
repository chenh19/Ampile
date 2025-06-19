#!/bin/bash
# universal for all unix/linux systems

# Set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# Check OS
case "$(uname -s)" in
    Linux)
        if [[ "$(uname -m)" == "x86_64" ]]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        elif [[ "$(uname -m)" == "aarch64" ]]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
        else
            echo -e "\n${TEXT_YELLOW}Unsupported Linux architecture: $(uname -m)${TEXT_RESET}\n" >&2
            exit 1
        fi;;
    Darwin)
        if [[ "$(uname -m)" == "x86_64" ]]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        elif [[ "$(uname -m)" == "arm64" ]]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            echo -e "\n${TEXT_YELLOW}Unsupported MacOS architecture: $(uname -m)${TEXT_RESET}\n" >&2
            exit 1
        fi;;
    FreeBSD)
        sudo pkg install -y R bwa fastqc fastp samtools bamtools parallel
        sudo Rscript -e "install.packages(c('tidyverse', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, repos = 'https://cloud.r-project.org')"
        exit 0;;
    *)  echo "Unsupported OS: $(uname -s)"
        exit 1;;
esac

# Install Miniconda
mkdir -p ~/miniconda3
curl -fsSL "$URL" -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# Initialize conda
source ~/miniconda3/bin/activate
conda init --all

# Disable auto-activation of base environment
conda config --set auto_activate_base false

# Disable conda initialization when opening a shell
if [[ -f ~/.bashrc ]]; then
  start0=$(( $(grep -wn "# >>> conda initialize >>>" ~/.bashrc | head -n 1 | cut -d: -f1) - 1 ))
  end0=$(( $(grep -wn "# <<< conda initialize <<<" ~/.bashrc | tail -n 1 | cut -d: -f1) + 1 ))
  if [[ -n "$start0" && -n "$end0" ]]; then sed -i "${start0},${end0}d" ~/.bashrc; fi
  if ! grep -q "alias conda-init='source ~/miniconda3/etc/profile.d/conda.sh'" ~/.bashrc ; then echo -e "alias conda-init='source ~/miniconda3/etc/profile.d/conda.sh'" >> ~/.bashrc ; fi
  unset start0 end0
fi
if [[ -f ~/.zshrc ]]; then
  start0=$(( $(grep -wn "# >>> conda initialize >>>" ~/.zshrc | head -n 1 | cut -d: -f1) - 1 ))
  end0=$(( $(grep -wn "# <<< conda initialize <<<" ~/.zshrc | tail -n 1 | cut -d: -f1) + 1 ))
  if [[ -n "$start0" && -n "$end0" ]]; then sed -i "${start0},${end0}d" ~/.zshrc; fi
  if ! grep -q "alias conda-init='source ~/miniconda3/etc/profile.d/conda.sh'" ~/.zshrc ; then echo -e "alias conda-init='source ~/miniconda3/etc/profile.d/conda.sh'" >> ~/.zshrc ; fi
  unset start0 end0
fi

# Refresh shell config
source ~/.bashrc

# Set up channels
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# Create a new environment for ampile
conda create -y -n ampile \
  conda-forge::r-base \
  conda-forge::r-littler \
  conda-forge::r-tidyverse \
  conda-forge::r-expss \
  conda-forge::r-filesstrings \
  conda-forge::r-foreach \
  conda-forge::r-doparallel \
  conda-forge::parallel \
  bioconda::bwa \
  bioconda::fastqc \
  bioconda::fastp \
  bioconda::samtools \
  bioconda::bamtools

# Update conda
conda update --all -y

# Activate environment ampile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate ampile

# Check packages
required_tools=("R" "bwa" "fastqc" "fastp" "samtools" "bamtools" "parallel")
for tool in "${required_tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo -e "\n${TEXT_GREEN}$tool package successfully installed.${TEXT_RESET}"
  fi
done
Rscript -e 'for (pkg in c("tidyverse", "expss", "filesstrings", "foreach", "doParallel")) if (suppressPackageStartupMessages(require(pkg, character.only = TRUE))) message("\nr-", pkg, " package successfully installed") else message("Failed to load: ", pkg)'
