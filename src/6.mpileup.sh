#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Generating pileup files...${TEXT_RESET}\n" && sleep 1

# create folders
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/4.mpileup/ ] && mkdir ./3.analysis/4.mpileup/

# pileup
ls ./3.analysis/3.bam/*.filtered.bam | parallel '
  bam={}
  base=$(basename "$bam" .filtered.bam)
  samtools mpileup -aa -A -B -Q 0 -d 2000000 -f ./3.analysis/1.refseq/refseq.fa "$bam" > ./3.analysis/4.mpileup/"$base".mpileup
'

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
