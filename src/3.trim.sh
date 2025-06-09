#!/bin/bash

# set terminal font color
TEXT_YELLOW=$(tput bold; tput setaf 3)
TEXT_GREEN=$(tput bold; tput setaf 2)
TEXT_RESET=$(tput sgr0)

# notify start
echo -e "\n${TEXT_YELLOW}Trimming and filtering reads...${TEXT_RESET}\n" && sleep 1

# create folders
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/2.trim/ ] && mkdir ./3.analysis/2.trim/

# trim by length and quality
threads=$(nproc)
for r1 in ./2.fastq/*_R1*.fastq*; do
    [ -f "$r1" ] || continue
    r2=$(echo "$r1" | sed -E 's/_R1/_R2/')
    if [[ "$r1" == *.fastq.gz ]]; then
        base=$(basename "$r1" .fastq.gz)
        sample=$(echo "$base" | sed -E 's/_R1//')
    elif [[ "$r1" == *.fastq ]]; then
        base=$(basename "$r1" .fastq)
        sample=$(echo "$base" | sed -E 's/_R1//')
    else
        continue
    fi

    cutadapt -j 8 -l 180 -o "./3.analysis/2.trim/${sample}_R1.cut.fastq.gz" $r1
    cutadapt -j 8 -l 180 -o "./3.analysis/2.trim/${sample}_R2.cut.fastq.gz" $r2

    fastp \
      -i "./3.analysis/2.trim/${sample}_R1.cut.fastq.gz" \
      -I "./3.analysis/2.trim/${sample}_R2.cut.fastq.gz" \
      -o "./3.analysis/2.trim/${sample}_R1.trimmed.fastq.gz" \
      -O "./3.analysis/2.trim/${sample}_R2.trimmed.fastq.gz" \
      --trim_front1 5 \
      --trim_front2 5 \
      --cut_tail \
      --cut_tail_window_size 4 \
      --cut_tail_mean_quality 20 \
      --length_required 80 \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 20 \
      --thread $threads \
      -j /dev/null \
      -h /dev/null

      rm -f "./3.analysis/2.trim/${sample}_R1.cut.fastq.gz" "./3.analysis/2.trim/${sample}_R2.cut.fastq.gz"
done

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
