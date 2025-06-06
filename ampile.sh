#!/bin/bash
[ ! -d ./1.ref/ ] && mkdir ./1.ref/
[ ! -d ./2.fastq/ ] && mkdir ./2.fastq/

# set terminal font color
TEXT_YELLOW='\e[1;33m'
TEXT_GREEN='\e[1;32m'
TEXT_RESET='\e[0m'

# check whether R is installed
if ! command -v R >/dev/null 2>&1; then
  echo -e "\n${TEXT_YELLOW}R is not installed. Please install R and try again.${TEXT_RESET}\n" >&2 && sleep 1
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

echo "good to go"

# process refseq
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/1.refseq.sh)"

# perform fastqc
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/2.fastqc.sh)"

# trim and filter reads
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/3.trim.sh)"

# perform fastqc again
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/4.refastqc.sh)"

# align
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/5.bam.sh)"

# pileup
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/6.mpileup.sh)"

# parse
#curl -fsSL https://raw.githubusercontent.com/chenh19/Amplie/refs/heads/main/src/7.parse.R | Rscript -

# plot
#curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/main/src/8.plot.R | Rscript -
