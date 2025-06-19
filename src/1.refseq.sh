#!/bin/bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Processing reference sequences...${TEXT_RESET}\n" && sleep 1

# create folders
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/1.refseq/ ] && mkdir ./3.analysis/1.refseq/

# combine and index refseq
cat ./1.ref/*.fa > ./3.analysis/1.refseq/refseq.fa
bwa index ./3.analysis/1.refseq/refseq.fa

# notify end
echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET} \n" && sleep 1
