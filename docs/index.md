---
title: Amplicon pileup analysis pipeline
toc: false
---

### [1/4] Setup environment

Pipeline failures are often due to an improperly configured environment. To ensure a robust and consistent setup for Ampile, I've created a dedicated configuration script. To execute the setup:

- Install ```curl``` if it is not already installed on your system.
- Connect to internet and execute the below command in terminal:

<pre> bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/setup.sh)" </pre>

<details>
<summary>**Note:**</summary>

<div style="font-size: 0.9em">

- This pipeline is dependent on: ```R```, ```bwa```, ```fastqc```, ```fastp```,  ```samtools```, ```bamtools```, ```parallel```, ```r-tidyverse```, ```r-expss```, ```r-filesstrings```, ```r-foreach```, ```r-doParallel```. It can be run in Linux, FreeBSD, and MacOS environments.
- The [ampile.sh](https://github.com/chenh19/Ampile/blob/main/ampile.sh) script will verify that all required packages are installed before proceeding with the analysis.
- The [setup.sh](https://github.com/chenh19/Ampile/blob/main/setup.sh) script requires no directory changes, and does not need administrative privileges on Linux.
- The pipeline has been tested on [Debian 12](https://www.debian.org/), [Ubuntu 24.04](https://ubuntu.com/), [Kubuntu 24.04](https://kubuntu.org/), [KDE Neon 20250616](https://neon.kde.org/), [Linux Mint 22.1](https://linuxmint.com/), [Zorin OS 17.3](https://zorin.com/), [Pop!_OS 22.04](https://system76.com/pop/), [Elementary OS 8](https://elementary.io/), [Fedora 42](https://www.fedoraproject.org/), [Rocky Linux 10](https://rockylinux.org/), [AlmaLinux 9](https://almalinux.org/), [RHEL 8 (UChicago Midway3)](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux), [CentOS 7 (UChicago Midway2)](https://www.centos.org/), [FreeBSD 14.3](https://www.freebsd.org/), and [MacOS Sequoia](https://www.apple.com/macos/). If you're using an unsupported OS or prefer an alternative setup method, please ensure that all required dependencies are installed.

</div>

</details>


### [2/4] Prepare input files

- Prepare reference sequences (```.fa``` files) and sequencing reads (```.fastq``` or ```.fastq.gz``` files) in a master folder (you may name the folder as desired):

<div style="text-align: center;">
  <img src="./images/0.png" width="100%">
</div>

- You may also organize the files into the two designated subfolders, ```./1.ref/``` and ```./2.fastq/```:

<div style="text-align: center;">
  <img src="./images/1.png" width="100%">
</div>

<details>
<summary>**Note:**</summary>

<div style="font-size: 0.9em">

- Example files are provided in the [/examples/](https://github.com/chenh19/Ampile/tree/main/examples) folder.
- The pipeline will automatically organize input files if they are not already in the two designated subfolders.
- The pipeline will also automatically compress sequencing reads to ```.fastq.gz``` if they are provided in ```.fastq``` format.

</div>

</details>


### [3/4] Running the pipeline

- Change current directory to the folder containing the input files. For example: ```cd ~/Desktop/Ampile/```
- Connect to internet and execute the below command in terminal:

<pre> bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/ampile.sh)" </pre>

<div style="text-align: center;">
  <img src="./images/2.png" width="90%">
</div>

- Alternatively, you may [download](https://github.com/chenh19/Ampile/archive/refs/heads/main.zip) the GitHub repository and place all scripts in the [/src/](https://github.com/chenh19/Ampile/tree/main/src) folder along with the input files to run them manually:

<div style="text-align: center;">
  <img src="./images/3.png" width="100%">
</div>

<details>
<summary>**Note:**</summary>

<div style="font-size: 0.9em">

- All scripts assume the master folder as the working directory.

</div>

</details>


### [4/4] Done

<div style="text-align: center;">
  <img src="./images/4.png" width="90%">
</div>

<div style="text-align: center;">
  <img src="./images/5.png" width="100%">
</div>

- You may further analyze the parsed mutation rates and perform comparative analyses between groups. The corresponding spreadsheets are located at ```./3.analysis/8.spreadsheets/3.mpileup_parse/```.

<details>
<summary>**Note:**</summary>

<div style="font-size: 0.9em">

- The directories ```./3.analysis/1.refseq/```, ```./3.analysis/2.trim/```, ```./3.analysis/3.bam/```, and ```./3.analysis/4.mpileup/``` contain large intermediate files. You may choose to delete them unless you need them for troubleshooting.

</div>

</details>
