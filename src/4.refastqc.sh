#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/4.refastqc/ ] && mkdir ./3.analysis/4.refastqc/

# install fastqc
sudo apt-get update -qq && sudo apt-get install fastqc -y

# run fastqc in parallel
fastqc --threads 16 ./3.analysis/3.trim/*.fastq ./3.analysis/3.trim/*.fastq.gz --outdir ./3.analysis/4.refastqc/

# extract per_base_quality.png
for zip in ./3.analysis/4.refastqc/*.zip; do
    base=$(basename "$zip" .zip)
    unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/4.refastqc/${base}_per_base_quality.png"
done

# cleanup
rm -f ./3.analysis/4.refastqc/*.html ./3.analysis/4.refastqc/*.zip
