---
title: Amplicon pileup analysis pipeline
toc: false
---

### [1/3] Prepare input files

- Prepare reference sequences and sequencing reads in a folder:

<div style="text-align: center;">
  <img src="./images/1.png" width="100%">
</div>


### [2/3] Running the pipeline

- Connect to internet.
- Open Terminal, change current directory to the folder containing the input files.
- Paste in the below code and press ```Enter``` to run:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/ampile.sh)"
```

<div style="text-align: center;">
  <img src="./images/2.png" width="90%">
</div>

- Or, you may [download the GitHub repo](https://github.com/chenh19/Ampile/archive/refs/heads/main.zip) and placed [all the scripts in /src/ folder](https://github.com/chenh19/Ampile/tree/main/src) with the input files to run manually:

<div style="text-align: center;">
  <img src="./images/3.png" width="100%">
</div>


### [3/3] Done
  
<div style="text-align: center;">
  <img src="./images/4.png" width="90%">
</div>

- You may further analyze the parsed mutation rates and perform comparative analyses between groups.
