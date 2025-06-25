#!/usr/bin/env bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Performing FastQC on trimmed reads...${TEXT_RESET}\n" && sleep 1

# check for trimmed fastq input
if ! find "./3.analysis/2.trim/" -maxdepth 1 -type f -name "*.fastq.gz" | grep -q .; then
  echo -e "${TEXT_YELLOW}Trimmed reads (.fastq.gz) were not found in ./3.analysis/2.trim/ folder, please double check.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# create folders
mkdir -p ./3.analysis/8.spreadsheets/1.read_counts/
mkdir -p ./3.analysis/9.plots/2.refastqc/

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
fastqc --threads $threads ./3.analysis/2.trim/*.fastq ./3.analysis/2.trim/*.fastq.gz --outdir ./3.analysis/9.plots/2.refastqc/

# extract per_base_quality.png
for zip in ./3.analysis/9.plots/2.refastqc/*.zip; do
  [ -f "$zip" ] || continue
  base=$(basename "$zip" .zip)
  unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/9.plots/2.refastqc/${base}_per_base_quality.png"
done
rm -f ./3.analysis/9.plots/2.refastqc/*.html ./3.analysis/9.plots/2.refastqc/*.zip

# count trimmed reads
echo -e "\nCounting trimmed reads:\n"
output_file="./3.analysis/8.spreadsheets/1.read_counts/trimmed_read_counts.csv"
> "$output_file"
for f in ./3.analysis/2.trim/*.fastq.gz; do
  [[ -f "$f" ]] || continue
  count=$(gzip -dc "$f" | awk 'END {print NR/4}')
  echo "  $(basename "$f"): $count reads"
  echo "$(basename "$f"), $count" >> "$output_file"
done

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
