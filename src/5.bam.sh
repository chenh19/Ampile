#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/3.bam/ ] && mkdir ./3.analysis/3.bam/

# set terminal font color
TEXT_YELLOW=$(tput bold; tput setaf 3)
TEXT_GREEN=$(tput bold; tput setaf 2)
TEXT_RESET=$(tput sgr0)

# notify start
echo -e "\n${TEXT_YELLOW}Mapping reads to the refseq...${TEXT_RESET}\n" && sleep 1

# align reads
for r1 in ./3.analysis/2.trim/*_R1*trimmed.fastq.gz; do
  [ -f "$r1" ] || continue
  r2=$(echo "$r1" | sed -E 's/_R1/_R2/')
  base=$(basename "$r1" .trimmed.fastq.gz)
  sample=$(echo "$base" | sed -E 's/_R1//')

  bwa mem -t 16 ./3.analysis/1.refseq/refseq.fa $r1 $r2 | \
    samtools sort -@ 16 -o ./3.analysis/3.bam/${sample}.bam
  samtools index ./3.analysis/3.bam/${sample}.bam

  bamtools filter -in ./3.analysis/3.bam/${sample}.bam -out ./3.analysis/3.bam/${sample}.filtered.bam -tag "NM:<34"
  samtools index ./3.analysis/3.bam/${sample}.filtered.bam

  rm -f ./3.analysis/3.bam/${sample}.bam ./3.analysis/3.bam/${sample}.bam.bai
done

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1

