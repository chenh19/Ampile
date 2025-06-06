#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/2.fastqc/ ] && mkdir ./3.analysis/2.fastqc/

# install fastqc
sudo apt-get update -qq && sudo apt-get install fastqc -y

# run fastqc in parallel
fastqc --threads 16 ./2.fastq/*.fastq ./2.fastq/*.fastq.gz --outdir ./3.analysis/2.fastqc/

# extract per_base_quality.png
for zip in ./3.analysis/2.fastqc/*.zip; do
    base=$(basename "$zip" .zip)
    unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/2.fastqc/${base}_per_base_quality.png"
done

# cleanup
rm -f ./3.analysis/2.fastqc/*.html ./3.analysis/2.fastqc/*.zip
