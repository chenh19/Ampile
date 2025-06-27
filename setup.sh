#!/usr/bin/env bash
# Universal setup script for unix/linux systems

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Setting up environment for Ampile pipeline...${TEXT_RESET}\n" && sleep 1
mkdir -p ~/.parallel/
[ ! -f ~/.parallel/will-cite ] && touch ~/.parallel/will-cite

# check OS
case "$(uname -s)" in
    Linux)
        if [[ "$(uname -m)" == "x86_64" ]]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        elif [[ "$(uname -m)" == "aarch64" ]]; then
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
        else
            echo -e "${TEXT_YELLOW}Unsupported Linux architecture: $(uname -m)${TEXT_RESET}\n" >&2
            exit 1
        fi
        ;;
    Darwin)
        [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
        [ ! -f ~/.zprofile ] && touch ~/.zprofile
        if [[ "$(uname -m)" == "x86_64" ]]; then
            URL="https://cran.r-project.org/bin/macosx/big-sur-x86_64/base/R-4.5.1-x86_64.pkg"
            if ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' ~/.bash_profile ; then echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile; fi
            if ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' ~/.zprofile ; then echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile; fi
        elif [[ "$(uname -m)" == "arm64" ]]; then
            URL="https://cran.r-project.org/bin/macosx/big-sur-arm64/base/R-4.5.1-arm64.pkg"
            if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.bash_profile ; then echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile; fi
            if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile ; then echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile; fi
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        else
            echo -e "\n${TEXT_YELLOW}Unsupported MacOS architecture: $(uname -m)${TEXT_RESET}\n" >&2
            exit 1
        fi
        printf "\n\033[1mInstall the Xcode Command Line Tools if a popup appears, then proceed.\033[0m\n\n"
	sleep 3
	xcode-select --install
        printf "\n\033[1mInitializing Homebrew setup...\033[0m\n\n"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	if [[ "$(uname -m)" == "x86_64" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        elif [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
	brew install bwa fastqc fastp samtools bamtools parallel
        curl -fsSL "$URL" -o ~/R.pkg
        sudo installer -pkg ~/R.pkg -target /
        rm -f ~/R.pkg
        Rscript -e "install.packages(c('tidyverse', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, repos = 'https://cloud.r-project.org')"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/check.sh)"
        exit 0
        ;;
    FreeBSD)
        if grep -q '^ID=freebsd' /etc/os-release 2>/dev/null; then
            sudo pkg upgrade -y && sudo pkg install -y R bwa fastqc fastp samtools bamtools parallel R-cran-tidyverse R-cran-foreach R-cran-doParallel zip
            sudo Rscript -e "install.packages(c('expss', 'filesstrings'), force = TRUE, repos = 'https://cloud.r-project.org')"
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/check.sh)"
            exit 0
        else
            OS_NAME=$(grep '^NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"')
            echo -e "${TEXT_YELLOW}Unsupported BSD: ${OS_NAME}${TEXT_RESET}\n" >&2
            exit 1
        fi
        ;;
    *)  echo -e "${TEXT_YELLOW}Unsupported OS: $(uname -s)${TEXT_RESET}\n" >&2
        exit 1
        ;;
esac

# install miniconda
mkdir -p ~/miniconda3
[ ! -f ~/.hidden ] && touch ~/.hidden
if ! grep -q "miniconda3" ~/.hidden ; then echo -e "miniconda3" >> ~/.hidden ; fi
if ! grep -q "bin" ~/.hidden ; then echo -e "bin" >> ~/.hidden ; fi
curl -fsSL "$URL" -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
[ ! -f ~/.condarc ] && touch ~/.condarc
rm ~/miniconda3/miniconda.sh

# initialize conda and refresh shell
source ~/miniconda3/bin/activate
conda init --all
source ~/.bashrc

# set up channels
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

# disable auto-activation of conda
if ! grep -q "auto_activate: false" ~/.condarc ; then conda config --set auto_activate false ; fi
# disable conda initialization when opening a shell
if [[ -f ~/.bashrc ]]; then
  start0=$(( $(grep -wn "# >>> conda initialize >>>" ~/.bashrc | head -n 1 | cut -d: -f1) - 1 ))
  end0=$(( $(grep -wn "# <<< conda initialize <<<" ~/.bashrc | tail -n 1 | cut -d: -f1) + 1 ))
  if [[ -n "$start0" && -n "$end0" ]]; then sed -i "${start0},${end0}d" ~/.bashrc; fi
  unset start0 end0
fi
if [[ -f ~/.zshrc ]]; then
  start0=$(( $(grep -wn "# >>> conda initialize >>>" ~/.zshrc | head -n 1 | cut -d: -f1) - 1 ))
  end0=$(( $(grep -wn "# <<< conda initialize <<<" ~/.zshrc | tail -n 1 | cut -d: -f1) + 1 ))
  if [[ -n "$start0" && -n "$end0" ]]; then sed -i "${start0},${end0}d" ~/.zshrc; fi
  unset start0 end0
fi

# update base
conda update --all -y

# create a new environment for ampile
conda create -y -n ampile \
  conda-forge::r-base=4.4.2 \
  conda-forge::r-tidyverse=2.0.0 \
  conda-forge::r-expss=0.11.6 \
  conda-forge::r-filesstrings=3.4.0 \
  conda-forge::r-foreach=1.5.2 \
  conda-forge::r-doparallel=1.0.17 \
  conda-forge::parallel=20250622 \
  bioconda::bwa=0.7.19 \
  bioconda::fastqc=0.12.1 \
  bioconda::fastp=1.0.1 \
  bioconda::samtools=1.22 \
  bioconda::bamtools=2.5.3

# activate and update ampile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate ampile
R CMD javareconf
conda update --all -y

# check installed packages
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chenh19/Ampile/refs/heads/main/check.sh)"

# deactivate ampile and base
conda deactivate
conda deactivate
