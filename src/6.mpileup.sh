#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Generating pileup files...${TEXT_RESET}\n" && sleep 1

# create folders
mkdir -p ./3.analysis/4.mpileup/
mkdir -p ~/.parallel/
[ ! -f ~/.parallel/will-cite ] && touch ~/.parallel/will-cite

# set threads for parallel processing
if command -v nproc >/dev/null 2>&1; then
  threads=$(nproc)
else
  threads=$(sysctl -n hw.ncpu)
fi
if [ "$threads" -gt 32 ]; then
  threads=32
fi

# pileup
ls ./3.analysis/3.bam/*.filtered.bam | parallel -j $threads '
  bam={}
  base=$(basename "$bam" .filtered.bam)
  samtools mpileup -aa -A -B -Q 0 -d 2000000 -f ./3.analysis/1.refseq/refseq.fa "$bam" > ./3.analysis/4.mpileup/"$base".mpileup
'

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
