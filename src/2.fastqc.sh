#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/8.spreadsheets/ ] && mkdir ./3.analysis/8.spreadsheets/
[ ! -d ./3.analysis/8.spreadsheets/1.raw_read_counts/ ] && mkdir ./3.analysis/8.spreadsheets/1.raw_read_counts/
[ ! -d ./3.analysis/9.plots/ ] && mkdir ./3.analysis/9.plots/
[ ! -d ./3.analysis/9.plots/1.fastqc/ ] && mkdir ./3.analysis/9.plots/1.fastqc/

# install fastqc
sudo apt-get update -qq && sudo apt-get install fastqc -y

# run fastqc in parallel
threads=$(nproc)
fastqc --threads $threads ./2.fastq/*.fastq ./2.fastq/*.fastq.gz --outdir ./3.analysis/9.plots/1.fastqc/

# extract per_base_quality.png
for zip in ./3.analysis/9.plots/1.fastqc/*.zip; do
    base=$(basename "$zip" .zip)
    unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/9.plots/1.fastqc/${base}_per_base_quality.png"
done
rm -f ./3.analysis/9.plots/1.fastqc/*.html ./3.analysis/9.plots/1.fastqc/*.zip

# count raw reads
echo -e "\nCounting raw reads...\n"
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
echo -e "\nDone.\n"
