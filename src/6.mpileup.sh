#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Generating pileup files...${TEXT_RESET}\n" && sleep 1

# check for bam files
if ! find "./3.analysis/3.bam/" -maxdepth 1 -type f -name "*.filtered.bam" | grep -q .; then
  echo -e "${TEXT_YELLOW}Aligned reads (.bam) were not found in ./3.analysis/3.bam/ folder, please double check.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

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
find ./3.analysis/3.bam/ -maxdepth 1 -name "*.filtered.bam" -print0 | parallel -0 -j $threads '
  bam="{}"
  base=$(basename "$bam" .filtered.bam)
  samtools mpileup -aa -A -B -Q 0 -d 2000000 -f ./3.analysis/1.refseq/refseq.fa "$bam" > ./3.analysis/4.mpileup/"$base".mpileup
'

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
