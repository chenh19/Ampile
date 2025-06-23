# Ampile
**Amplicon pileup analysis pipeline**  
*Current version: v1.0.9*  

### Introduction

- This is Hang's analysis pipeline for amplicon-based mutational profiling.
- The tool calculates absolute mutation rates for each sample.
- For comparative analyses between groups, please perform those manually with the output spreadsheets.

#### How to setup the environment:

- Install ```curl``` if it is not already installed on your system.
- Connect to internet and execute the below command in terminal:
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/setup.sh)"
```

#### How to run the pipeline:

- Prepare reference sequences and sequencing reads in a folder (example files are provided in the [/examples/](https://github.com/chenh19/Ampile/tree/main/examples) folder.)
- Connect to internet and execute the below command in terminal:
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/ampile.sh)"
```
- There is also a simple [**tutorial**](https://chenh19.github.io/Ampile/) for quick reference.
