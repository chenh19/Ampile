#!/bin/bash
[ ! -d ./3.analysis/ ] && mkdir ./3.analysis/
[ ! -d ./3.analysis/9.plot/ ] && mkdir ./3.analysis/9.plot/
[ ! -d ./3.analysis/9.plot/2.refastqc/ ] && mkdir ./3.analysis/9.plot/2.refastqc/

# install fastqc
sudo apt-get update -qq && sudo apt-get install fastqc -y

# run fastqc in parallel
threads=$(nproc)
fastqc --threads $threads ./3.analysis/2.trim/*.fastq ./3.analysis/2.trim/*.fastq.gz --outdir ./3.analysis/9.plot/2.refastqc/

# extract per_base_quality.png
for zip in ./3.analysis/9.plot/2.refastqc/*.zip; do
    base=$(basename "$zip" .zip)
    unzip -p "$zip" "${base}/Images/per_base_quality.png" > "./3.analysis/9.plot/2.refastqc/${base}_per_base_quality.png"
done

# cleanup
rm -f ./3.analysis/9.plot/2.refastqc/*.html ./3.analysis/9.plot/2.refastqc/*.zip
