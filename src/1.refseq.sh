#!/usr/bin/env bash

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Processing reference sequences...${TEXT_RESET}\n" && sleep 1

# check for refseq input
if ! find "./1.ref/" -maxdepth 1 -type f -name "*.fa" | grep -q .; then
  echo -e "${TEXT_YELLOW}Reference sequences (.fa) were not found in ./1.ref/ folder, please prepare them and try again.${TEXT_RESET}\n" >&2 && sleep 1
  exit 1
fi

# create folders
mkdir -p ./3.analysis/1.refseq/

# combine and index refseq
cat ./1.ref/*.fa | grep -v '^[[:space:]]*$' > ./3.analysis/1.refseq/refseq.fa
bwa index ./3.analysis/1.refseq/refseq.fa

# notify end
error=0
if ! ls ./3.analysis/1.refseq/refseq.fa.{amb,ann,bwt,pac,sa} >/dev/null 2>&1; then
  echo -e "\n${TEXT_YELLOW}Error: failed to index reference sequences, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
  error=1
fi
if ! head -n 1 ./3.analysis/1.refseq/refseq.fa | grep -q '^>' || ! awk 'NR==1 {exit !($1 > 0)}' ./3.analysis/1.refseq/refseq.fa.amb; then
  echo -e "\n${TEXT_YELLOW}Error: invalid reference sequences, please check input files.${TEXT_RESET}\n" >&2 && sleep 1
  error=1
fi
if (( error )); then
  exit 1
else
  echo -e "\n${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
fi
