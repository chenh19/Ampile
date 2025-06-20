#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Mapping reads to the refseq...${TEXT_RESET}\n" && sleep 1

# create folders
mkdir -p ./3.analysis/3.bam/

# set threads for parallel processing
if command -v nproc >/dev/null 2>&1; then
  threads=$(nproc)
else
  threads=$(sysctl -n hw.ncpu)
fi
if [ "$threads" -gt 32 ]; then
  threads=32
fi

# align reads in parallel
for r1 in ./3.analysis/2.trim/*_R1*trimmed.fastq.gz; do
  [ -f "$r1" ] || continue
  r2=$(echo "$r1" | sed -E 's/_R1/_R2/')
  base=$(basename "$r1" .trimmed.fastq.gz)
  sample=$(echo "$base" | sed -E 's/_R1//')

  bwa mem -t $threads ./3.analysis/1.refseq/refseq.fa $r1 $r2 | \
    samtools sort -@ $threads -o ./3.analysis/3.bam/${sample}.bam
  samtools index ./3.analysis/3.bam/${sample}.bam

  bamtools filter -in ./3.analysis/3.bam/${sample}.bam -out ./3.analysis/3.bam/${sample}.filtered.bam -tag "NM:<6"
  samtools index ./3.analysis/3.bam/${sample}.filtered.bam

  rm -f ./3.analysis/3.bam/${sample}.bam ./3.analysis/3.bam/${sample}.bam.bai
done

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1

