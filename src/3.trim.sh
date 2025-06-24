#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Trimming and filtering reads...${TEXT_RESET}\n" && sleep 1

# check for fastq input
if ! (find "./2.fastq/" -maxdepth 1 -type f \( -name "*.fastq" -o -name "*.fastq.gz" \) | grep -q .); then
  echo -e "${TEXT_YELLOW}Sequencing data (.fastq or .fastq.gz) were not found in ./2.fastq/ folder, please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# create folders
mkdir -p ./3.analysis/2.trim/error_files/

# set threads for parallel processing
if command -v nproc >/dev/null 2>&1; then
  threads=$(nproc)
else
  threads=$(sysctl -n hw.ncpu)
fi
if [ "$threads" -gt 32 ]; then
  threads=32
fi

# set required length
length=$(awk -F',' 'NR > 1 {sum += $2; count++} END {if (count > 0) printf "%.0f", sum / count * 0.55}' ./3.analysis/8.spreadsheets/1.read_counts/sequence_lengths.csv)
if [ -z "$length" ]; then length=70; fi

# trim reads in parallel
for r1 in ./2.fastq/*_R1*.fastq.gz; do
  [ -f "$r1" ] || continue
  r2=$(echo "$r1" | sed -E 's/_R1/_R2/')
  base=$(basename "$r1" .fastq.gz)
  sample=$(echo "$base" | sed -E 's/_R1//')
  fastp \
    -i $r1 \
    -I $r2 \
    -o "./3.analysis/2.trim/${sample}_R1.trimmed.fastq.gz" \
    -O "./3.analysis/2.trim/${sample}_R2.trimmed.fastq.gz" \
    --trim_front1 5 \
    --trim_front2 5 \
    --cut_tail \
    --cut_tail_window_size 4 \
    --cut_tail_mean_quality 20 \
    --length_required $length \
    --qualified_quality_phred 20 \
    --unqualified_percent_limit 20 \
    --thread $threads \
    -j /dev/null \
    -h /dev/null
done

# check trimmed fastq files
find ./3.analysis/2.trim/ -maxdepth 1 -name "*.fastq.gz" -print0 | parallel -0 -j $threads '
  file="{}"
  if [ ! -f "$file" ]; then
    mv -f "$file" ./3.analysis/2.trim/error_files/
  else
    line_count=$(wc -l < "$file")
    if [ "$line_count" -lt 4 ]; then
      base=$(basename "$file")
      mv -f "$file" ./3.analysis/2.trim/error_files/
      echo -e "\n  Error: $base has no reads and will be excluded from further analysis." >&2
    fi
  fi
'
find ./3.analysis/2.trim/ -maxdepth 1 -name "*_R1*" -print0 | parallel -0 -j $threads '
  file="{}"
  counterpart="${file/_R1/_R2}"
  if [ ! -f "$counterpart" ]; then
    mv -f "$file" ./3.analysis/2.trim/error_files/
  fi
'
find ./3.analysis/2.trim/ -maxdepth 1 -name "*_R2*" -print0 | parallel -0 -j $threads '
  file="{}"
  counterpart="${file/_R2/_R1}"
  if [ ! -f "$counterpart" ]; then
    mv -f "$file" ./3.analysis/2.trim/error_files/
  fi
'

# notify end
if ! find "./3.analysis/2.trim/" -maxdepth 1 -type f -name "*.fastq.gz" | grep -q .; then
  echo -e "\n${TEXT_YELLOW}No reads remain after trimming and filtering, please review the FastQC results.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
else
  if [ "$(ls -1 ./3.analysis/2.trim/error_files/ | wc -l)" -eq 0 ]; then rm -rf ./3.analysis/2.trim/error_files/; fi
  echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
fi
