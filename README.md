# Ampile
**Amplicon pileup analysis pipeline**  
*Current version: v1.2.2*  

### Introduction

- This is Hang's analysis pipeline for amplicon-based mutational profiling.
- The tool calculates absolute mutation rates for each sample.
- For comparative analyses between groups, please perform those manually with the output spreadsheets.

#### How to setup the environment:

- Install ```curl``` if it is not already installed on your system (e.g., ```sudo apt install curl``` on Ubuntu).
- Connect to internet and execute the below command in terminal:
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/setup.sh)"
```

#### How to run the pipeline:

- Prepare reference sequences and sequencing reads in a folder ([examples files available](https://github.com/chenh19/Ampile/tree/main/examples)).
- Connect to internet and execute the below command in terminal:
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/ampile.sh)"
```
- There is also a simple [**tutorial**](https://chenh19.github.io/Ampile/) for quick reference.

#### To-do:

- [ ] include .fasta refseq processing
- [ ] if multiple refseqs, plot for each amplicon (currently it will overlay the amplicons)
- [ ] include long-read fastq processing (minimap2)
- [ ] allow space in input (.fa and .fastq) file names
- [ ] interactive delta mutation rate analysis (maybe Shiny)
