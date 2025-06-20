#!/bin/bash
# Ampile pipeline

# activate conda
[ -f ~/miniconda3/etc/profile.d/conda.sh ] && source ~/miniconda3/etc/profile.d/conda.sh && conda activate ampile

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# check required packages
missing=0
required_tools=("R" "bwa" "fastqc" "fastp" "samtools" "bamtools" "parallel")
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo -e "\n${TEXT_YELLOW}Error: $tool is not installed.${TEXT_RESET}" >&2 
    missing=1
  fi
done
output=$(Rscript -e 'for (pkg in c("tidyverse", "expss", "filesstrings", "foreach", "doParallel")) if (!suppressPackageStartupMessages(require(pkg, character.only = TRUE))) cat("\n", "\033[1;33m", "Error: r-", pkg, " is not installed.", "\033[0m", "\n", sep = "")' 2>/dev/null)
if echo "$output" | grep -q "Error:"; then
  echo "$output"
  missing=1
fi
if (( missing )); then
  echo -e "\n${TEXT_YELLOW}Please setup the workspace and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# organize input files
[ ! -d ./1.ref/ ] && mkdir ./1.ref/
[ ! -d ./2.fastq/ ] && mkdir ./2.fastq/
find . -maxdepth 1 -type f -name "*.fa" -exec mv -f {} ./1.ref/ \;
find . -maxdepth 1 -type f -name "*.fastq*" -exec mv -f {} ./2.fastq/ \;
find ./2.fastq/ -maxdepth 1 -type f -name "*.fastq" -print0 | parallel -0 gzip -f

# check input files
if ! find "./1.ref/" -maxdepth 1 -type f -name "*.fa" | grep -q .; then
  echo -e "\n${TEXT_YELLOW}Reference sequences (.fa) were not found in ./1.ref/ folder. Please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi
if ! (find "./2.fastq/" -maxdepth 1 -type f \( -name "*.fastq" -o -name "*.fastq.gz" \) | grep -q .); then
  echo -e "\n${TEXT_YELLOW}Sequencing data (.fastq or .fastq.gz) were not found in ./2.fastq/ folder. Please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# process refseq
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/1.refseq.sh)"

  ## check whether successfully indexed
  if ! ls ./3.analysis/1.refseq/refseq.fa.{amb,ann,bwt,pac,sa} >/dev/null 2>&1; then
    echo -e "\n${TEXT_YELLOW}Error: failed to index reference sequences, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
    exit 1
  fi

# perform fastqc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/2.fastqc.sh)"

  ## check whether paired-end short-read data
  while IFS=, read -r fastq_file max_length; do
    if [[ "$fastq_file" != *R1* && "$fastq_file" != *R2* ]]; then
      echo -e "\n${TEXT_YELLOW}Error: expecting paired-end short-read sequencing data, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
      exit 1
    fi
    if (( max_length > 350 )); then
      echo -e "\n${TEXT_YELLOW}Error: expecting paired-end short-read sequencing data, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
      exit 1
    fi
  done < <(tail -n +2 ./3.analysis/8.spreadsheets/1.raw_read_counts/sequence_lengths.csv)

# trim and filter reads
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/3.trim.sh)"

# perform fastqc again
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/4.refastqc.sh)"

# align
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/5.bam.sh)"

# pileup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/6.mpileup.sh)"

# parse
curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/7.parse.R | Rscript -

  # archive output spreadsheet
  echo -e "Zipping mutation rate spreadsheets...\n"
  zip -j ./3.analysis/8.spreadsheets/3.mpileup_parse/mpileup_parse.zip ./3.analysis/8.spreadsheets/3.mpileup_parse/*.csv
  
# plot
curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/8.plot.R | Rscript -

# cleanup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/9.cleanup.sh)"

# deactivate conda
[ -f ~/miniconda3/etc/profile.d/conda.sh ] && conda deactivate
