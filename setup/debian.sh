#!/bin/bash
# for debian and derivatives

## check codenames
source /etc/os-release
CODENAME=$VERSION_CODENAME
DISTRO=$ID

## install packages and dependencies
sudo apt-get update -qq && sudo apt-get install wget bwa fastqc fastp samtools bamtools default-jre default-jdk cmake pandoc libcurl4-openssl-dev libssl-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libjpeg-dev libtiff-dev libtiff5-dev libgit2-dev libglpk-dev libnlopt-dev libgeos-dev libxml2-dev libv8-dev libcairo2-dev -y

## install R from cran
if [[ "$DISTRO" == "debian" ]]; then
  gpg --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
  gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' | sudo tee /etc/apt/trusted.gpg.d/cran_debian_key.asc
  echo -e "deb https://cloud.r-project.org/bin/linux/debian ${CODENAME}-cran40/" | sudo tee /etc/apt/sources.list.d/r-project.list
elif [[ "$DISTRO" == *buntu ]]; then
  wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
  sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu ${CODENAME}-cran40/"
else
  echo "Unsupported distribution: $DISTRO"
  exit 1
fi
sudo apt-get update -qq && sudo apt-get install r-base littler -y && sudo R CMD javareconf

## config posit package manager
if ! grep -q "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/${CODENAME}/latest'))" /etc/R/Rprofile.site ; then echo -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/${CODENAME}/latest'))" | sudo tee -a /etc/R/Rprofile.site ; fi

## install R packages
sudo Rscript -e "install.packages(c('tidyverse', 'ggplot2', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, Ncpus = system('nproc --all', intern = TRUE), repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/${CODENAME}/latest'))"
