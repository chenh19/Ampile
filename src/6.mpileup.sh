#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/6.mpileup/ ] && mkdir ./3.analysis/6.mpileup/

# install samtools
sudo apt-get update -qq && sudo apt-get install samtools -y

# pileup
for bam in ./3.analysis/5.bam/*.filtered.bam; do
  base=$(basename "$bam" .filtered.bam)
  samtools mpileup -aa -A -B -Q 0 -d 2000000 -f ./3.analysis/1.refseq/refseq.fa "$bam" > ./3.analysis/6.mpileup/"$base".mpileup
done

# cleanup
rm -f ./3.analysis/5.bam/*.filtered.bam ./3.analysis/5.bam/*.filtered.bam.bai
echo -e "" > ./3.analysis/5.bam/large_intermediate_files_deleted.txt
