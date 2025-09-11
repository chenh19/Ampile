#!/usr/bin/env bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Performing FastQC on raw reads...${TEXT_RESET}\n" && sleep 1

# check for fastq input
if ! (find "./2.fastq/" -maxdepth 1 -type f \( -name "*.fastq" -o -name "*.fastq.gz" \) | grep -q .); then
  echo -e "${TEXT_YELLOW}Sequencing data (.fastq or .fastq.gz) were not found in ./2.fastq/ folder, please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# create folders
mkdir -p ./3.analysis/8.spreadsheets/1.read_counts/
mkdir -p ./3.analysis/9.plots/1.fastqc/

# set threads for parallel processing
if command -v nproc >/dev/null 2>&1; then
  threads=$(nproc)
else
  threads=$(sysctl -n hw.ncpu)
fi
if [ "$threads" -gt 32 ]; then
  threads=32
fi

# run fastqc in parallel
fastqc --threads $threads ./2.fastq/*.fastq ./2.fastq/*.fastq.gz --outdir ./3.analysis/9.plots/1.fastqc/

# extract per_base_quality.png and read_lengths
echo "fastq_file,max_length" > "./3.analysis/8.spreadsheets/1.read_counts/sequence_lengths.csv"
for zip in ./3.analysis/9.plots/1.fastqc/*.zip; do
  [ -f "$zip" ] || continue
  base=$(basename "$zip" .zip)
  base_short=$(basename "$zip" _fastqc.zip)
  unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/9.plots/1.fastqc/${base}_per_base_quality.png"
  max_len=$(unzip -p "$zip" "${base}/fastqc_data.txt" | awk -F '\t' '/Sequence length/ {split($2,a,"-"); print a[length(a)]}')
  echo "$base_short,$max_len" >> "./3.analysis/8.spreadsheets/1.read_counts/sequence_lengths.csv"
done
rm -f ./3.analysis/9.plots/1.fastqc/*.html ./3.analysis/9.plots/1.fastqc/*.zip

# count raw reads
echo -e "\nCounting raw reads:\n"
output_file="./3.analysis/8.spreadsheets/1.read_counts/raw_read_counts.csv"
> "$output_file"
for f in ./2.fastq/*.fastq.gz; do
  [[ -f "$f" ]] || continue
  count=$(gzip -dc "$f" | awk 'END {print NR/4}')
  echo "  $(basename "$f"): $count reads"
  echo "$(basename "$f"),$count" >> "$output_file"
done

# check whether paired-end short-read data
while IFS=, read -r fastq_file max_length; do
  if [[ "$fastq_file" != *R1* && "$fastq_file" != *R2* ]]; then
    echo -e "\n${TEXT_YELLOW}Error: expecting paired-end short-read sequencing data, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
    exit 1
  fi
  if (( max_length > 350 )); then
    echo -e "\n${TEXT_YELLOW}Error: expecting paired-end short-read sequencing data, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
    exit 1
  fi
done < <(tail -n +2 ./3.analysis/8.spreadsheets/1.read_counts/sequence_lengths.csv)

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
