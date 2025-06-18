#!/bin/bash

# set terminal font color
TEXT_YELLOW=$(tput bold; tput setaf 3)
TEXT_GREEN=$(tput bold; tput setaf 2)
TEXT_RESET=$(tput sgr0)

# create folders
[ ! -d ./1.ref/ ] && mkdir ./1.ref/
[ ! -d ./2.fastq/ ] && mkdir ./2.fastq/

# check whether required packages are all installed
required_tools=("R" "bwa" "fastqc" "fastp" "cutadapt" "samtools" "bamtools")
missing=0
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo -e "\n${TEXT_YELLOW}$tool is not installed.${TEXT_RESET}" >&2 
    missing=1
  fi
done
if (( missing )); then
  echo -e "\n${TEXT_YELLOW}Please setup the workspace and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# check whether refseq files are placed in ./1.ref/
if ! find "./1.ref/" -maxdepth 1 -type f -name "*.fa" | grep -q .; then
  echo -e "\n${TEXT_YELLOW}Reference sequences (.fa) were not found in ./1.ref/ folder. Please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# check whether .fastq or .fastq.gz files are placed in ./2.fastq/
if ! (find "./2.fastq/" -maxdepth 1 -type f \( -name "*.fastq" -o -name "*.fastq.gz" \) | grep -q .); then
  echo -e "\n${TEXT_YELLOW}Sequencing data (.fastq or .fastq.gz) were not found in ./2.fastq/ folder. Please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# process refseq
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/1.refseq.sh)"

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

# plot
curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/8.plot.R | Rscript -

# cleanup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/src/9.cleanup.sh)"
