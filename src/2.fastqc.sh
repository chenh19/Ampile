#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Performing FastQC on raw reads...${TEXT_RESET}\n" && sleep 1

# create folders
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/8.spreadsheets/ ] && mkdir ./3.analysis/8.spreadsheets/
[ ! -d ./3.analysis/8.spreadsheets/1.raw_read_counts/ ] && mkdir ./3.analysis/8.spreadsheets/1.raw_read_counts/
[ ! -d ./3.analysis/9.plots/ ] && mkdir ./3.analysis/9.plots/
[ ! -d ./3.analysis/9.plots/1.fastqc/ ] && mkdir ./3.analysis/9.plots/1.fastqc/

# run fastqc in parallel
if command -v nproc >/dev/null 2>&1; then
    threads=$(nproc)
else
    threads=$(sysctl -n hw.ncpu)
fi
if [ "$threads" -gt 32 ]; then
  threads=32
fi
fastqc --threads $threads ./2.fastq/*.fastq ./2.fastq/*.fastq.gz --outdir ./3.analysis/9.plots/1.fastqc/

# extract per_base_quality.png and read_lengths
echo "fastq_file,max_length" > "./3.analysis/8.spreadsheets/1.raw_read_counts/sequence_lengths.csv"
for zip in ./3.analysis/9.plots/1.fastqc/*.zip; do
    base=$(basename "$zip" .zip)
    base_short=$(basename "$zip" _fastqc.zip)
    unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/9.plots/1.fastqc/${base}_per_base_quality.png"
    max_len=$(unzip -p "$zip" "${base}/fastqc_data.txt" | awk -F '\t' '/Sequence length/ {split($2,a,"-"); print a[length(a)]}')
    echo "$base_short,$max_len" >> "./3.analysis/8.spreadsheets/1.raw_read_counts/sequence_lengths.csv"
done
rm -f ./3.analysis/9.plots/1.fastqc/*.html ./3.analysis/9.plots/1.fastqc/*.zip

# count raw reads
echo -e "\nCounting raw reads:\n"
output_file="./3.analysis/8.spreadsheets/1.raw_read_counts/raw_read_counts.csv"
> "$output_file"
for f in ./2.fastq/*.fastq ./2.fastq/*.fastq.gz; do
  [[ -f "$f" ]] || continue
  if [[ "$f" == *.gz ]]; then
    count=$(gzip -dc "$f" | awk 'END {print NR/4}')
  else
    count=$(awk 'END {print NR/4}' "$f")
  fi
  echo "  $(basename "$f"): $count reads"
  echo "$(basename "$f"), $count" >> "$output_file"
done

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
