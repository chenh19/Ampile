#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/9.plots/ ] && mkdir ./3.analysis/9.plots/
[ ! -d ./3.analysis/8.spreadsheets/ ] && mkdir ./3.analysis/8.spreadsheets/
[ ! -d ./3.analysis/8.spreadsheets/2.trimmed_read_counts/ ] && mkdir ./3.analysis/8.spreadsheets/2.trimmed_read_counts/
[ ! -d ./3.analysis/9.plots/2.refastqc/ ] && mkdir ./3.analysis/9.plots/2.refastqc/

# install fastqc
sudo apt-get update -qq && sudo apt-get install fastqc -y

# run fastqc in parallel
threads=$(nproc)
fastqc --threads $threads ./3.analysis/2.trim/*.fastq ./3.analysis/2.trim/*.fastq.gz --outdir ./3.analysis/9.plots/2.refastqc/

# extract per_base_quality.png
for zip in ./3.analysis/9.plots/2.refastqc/*.zip; do
    base=$(basename "$zip" .zip)
    unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/9.plots/2.refastqc/${base}_per_base_quality.png"
done
rm -f ./3.analysis/9.plots/2.refastqc/*.html ./3.analysis/9.plots/2.refastqc/*.zip

# count trimmed reads
echo -e "\nCounting trimmed reads...\n"
output_file="./3.analysis/8.spreadsheets/2.trimmed_read_counts/trimmed_read_counts.csv"
> "$output_file"
for f in ./3.analysis/2.trim/*.fastq ./3.analysis/2.trim/*.fastq.gz; do
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
