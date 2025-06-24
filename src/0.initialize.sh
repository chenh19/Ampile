#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Initializing Ampile...${TEXT_RESET}" && sleep 1

# set threads for parallel processing
if command -v nproc >/dev/null 2>&1; then
  threads=$(nproc)
else
  threads=$(sysctl -n hw.ncpu)
fi
if [ "$threads" -gt 32 ]; then
  threads=32
fi

# check required packages
echo -e "\n${TEXT_YELLOW}Checking required packages...${TEXT_RESET}\n" && sleep 1
error=0
required_tools=("R" "bwa" "fastqc" "fastp" "samtools" "bamtools" "parallel")
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo -e "${TEXT_YELLOW}  Error: $tool is not installed.${TEXT_RESET}\n" >&2
    error=1
  fi
done
output=$(Rscript -e 'for (pkg in c("tidyverse", "expss", "filesstrings", "foreach", "doParallel")) if (!suppressWarnings(suppressPackageStartupMessages(require(pkg, character.only = TRUE)))) cat("\033[1;33m", "Error: r-", pkg, " is not installed.", "\033[0m", "\n\n", sep = "")' 2>/dev/null)
if echo "$output" | grep -q "Error:"; then
  echo "  $output" && echo ""
  error=1
fi
if (( error )); then
  echo -e "${TEXT_YELLOW}Please setup the workspace and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
else
  echo -e "${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
fi

# organize input files
echo -e "\n${TEXT_YELLOW}Organizing input files...${TEXT_RESET}\n" && sleep 1
error=0
mkdir -p ./1.ref/error_files/
find . -maxdepth 1 -type f -name "*.fa" -exec mv -f {} ./1.ref/ \;
find ./1.ref/ -maxdepth 1 -name "*.fa" -print0 | parallel -0 -j $threads '
  file="{}"
  if [ ! -f "$file" ]; then
    mv -f "$file" ./1.ref/error_files/
  else
    line_count=$(wc -l < "$file")
    if [ "$line_count" -lt 2 ]; then
      mv -f "$file" ./1.ref/error_files/
    fi
  fi
'
if ! find "./1.ref/" -maxdepth 1 -type f -name "*.fa" | grep -q .; then
  echo -e "${TEXT_YELLOW}Reference sequences (.fa) were not found in ./1.ref/ folder, please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  error=1
fi
mkdir -p ./2.fastq/error_files/
find . -maxdepth 1 -type f -name "*.fastq" -exec mv -f {} ./2.fastq/ \;
find . -maxdepth 1 -type f -name "*.fastq.gz" -exec mv -f {} ./2.fastq/ \;
find ./2.fastq/ -maxdepth 1 -type f -name "*.fastq" -print0 | parallel -0 -j "$threads" gzip -f
find ./2.fastq/ -maxdepth 1 -name "*.fastq.gz" -print0 | parallel -0 -j $threads '
  file="{}"
  if [ ! -f "$file" ]; then
    mv -f "$file" ./2.fastq/error_files/
  else
    line_count=$(wc -l < "$file")
    if [ "$line_count" -lt 4 ]; then
      mv -f "$file" ./2.fastq/error_files/
    fi
  fi
'
find ./2.fastq/ -maxdepth 1 -name "*_R1*" -print0 | parallel -0 -j $threads '
  file="{}"
  counterpart="${file/_R1/_R2}"
  if [ ! -f "$counterpart" ]; then
    mv -f "$file" ./2.fastq/error_files/
  fi
'
find ./2.fastq/ -maxdepth 1 -name "*_R2*" -print0 | parallel -0 -j $threads '
  file="{}"
  counterpart="${file/_R2/_R1}"
  if [ ! -f "$counterpart" ]; then
    mv -f "$file" ./2.fastq/error_files/
  fi
'
if ! (find "./2.fastq/" -maxdepth 1 -type f \( -name "*.fastq" -o -name "*.fastq.gz" \) | grep -q .); then
  echo -e "${TEXT_YELLOW}Sequencing data (.fastq or .fastq.gz) were not found in ./2.fastq/ folder, please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  error=1
fi
if (( error )); then
  exit 1
else
  if [ "$(ls -1 ./1.ref/error_files/ | wc -l)" -eq 0 ]; then rm -rf ./1.ref/error_files/; fi
  if [ "$(ls -1 ./2.fastq/error_files/ | wc -l)" -eq 0 ]; then rm -rf ./2.fastq/error_files/; fi
  echo -e "${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
fi
