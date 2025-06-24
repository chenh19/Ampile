#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Generating bam files...${TEXT_RESET}\n" && sleep 1

# check for trimmed fastq input
if ! find "./3.analysis/2.trim/" -maxdepth 1 -type f -name "*.fastq.gz" | grep -q .; then
  echo -e "${TEXT_YELLOW}Trimmed reads (.fastq.gz) were not found in ./3.analysis/2.trim/ folder, please double check.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# create folders
mkdir -p ./3.analysis/3.bam/error_files/

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

# check aligned reads
find ./3.analysis/3.bam/ -maxdepth 1 -name "*.filtered.bam" -print0 | parallel -0 -j $threads '
  bam="{}"
  if [ "$(samtools view "$bam" | wc -l)" -lt 1 ]; then
    base=$(basename "$bam")
    bai="${bam}.bai"
    mv -f "$bam" "$bai" ./3.analysis/3.bam/error_files/
    echo -e "\n  Error: $base has no aligned reads and will be excluded from further analysis." >&2
  fi
'

# notify end
if ! find "./3.analysis/3.bam/" -maxdepth 1 -type f -name "*.filtered.bam" | grep -q .; then
  echo -e "\n${TEXT_YELLOW}No reads were mapped to the refseq, please double check.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
else
  if [ "$(ls -1 ./3.analysis/3.bam/error_files/ | wc -l)" -eq 0 ]; then rm -rf ./3.analysis/3.bam/error_files/; fi
  echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
fi
