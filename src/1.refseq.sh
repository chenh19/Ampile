#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/1.refseq/ ] && mkdir ./3.analysis/1.refseq/

# install bwa
sudo apt-get update -qq && sudo apt-get install bwa -y

# combine refseq
cat ./1.ref/*.fa > ./3.analysis/1.refseq/refseq.fa
bwa index ./3.analysis/1.refseq/refseq.fa
