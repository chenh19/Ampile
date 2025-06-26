#!/usr/bin/env bash
# Universal setup script for unix/linux systems
# Thanks to Xiaocheng Yu for kindly letting me run tests on her Mac

# set terminal font color
TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
TEXT_GREEN="$(tput bold)$(tput setaf 2)"
TEXT_RESET="$(tput sgr0)"

# notify start
echo -e "\n${TEXT_YELLOW}Setting up environment for Ampile pipeline...${TEXT_RESET}\n" && sleep 1
mkdir -p ~/.parallel/
[ ! -f ~/.parallel/will-cite ] && touch ~/.parallel/will-cite

# check installed package function
check_installed_packages() {
    TEXT_GREEN="$(tput bold)$(tput setaf 2)"
    TEXT_RESET="$(tput sgr0)"
    printf "\nChecking packages:\n\n"
    required_tools="R bwa fastqc fastp samtools bamtools parallel"
    for tool in $required_tools; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf "  - Successfully installed: %s\n\n" "$tool"
        else
            printf "  x Failed to install: %s\n\n" "$tool"
        fi
    done
    Rscript -e 'for (pkg in c("tidyverse", "expss", "filesstrings", "foreach", "doParallel")) if (suppressWarnings(suppressPackageStartupMessages(require(pkg, character.only = TRUE)))) message("  - Successfully installed: r-", pkg, "\n") else message("  x Failed to install: r-", pkg, "\n")'
    printf "\n%sEnvironment setup complete! You may now proceed to run the Ampile pipeline.%s\n\n\n" "$TEXT_GREEN" "$TEXT_RESET"
    sleep 1
}

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
        if [[ "$(uname -m)" == "x86_64" ]]; then
            URL="https://cran.r-project.org/bin/macosx/big-sur-x86_64/base/R-4.5.1-x86_64.pkg"
        elif [[ "$(uname -m)" == "arm64" ]]; then
            URL="https://cran.r-project.org/bin/macosx/big-sur-arm64/base/R-4.5.1-arm64.pkg"
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        else
            echo -e "\n${TEXT_YELLOW}Unsupported MacOS architecture: $(uname -m)${TEXT_RESET}\n" >&2
            exit 1
        fi
        xcode-select --install
        printf "\n\n\033[1mPlease install the Xcode Command Line Tools if prompted by a popup window.\033[0m\n\n"
        printf "\n\033[1mSetting up homebrew...\033[0m\n\n"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$($(which brew) shellenv)"' >> ~/.bash_profile
        echo 'eval "$($(which brew) shellenv)"' >> ~/.zprofile
        eval "$($(which brew) shellenv)"
        brew install bwa fastqc fastp samtools bamtools parallel
        curl -fsSL "$URL" -o ~/R.pkg
        sudo installer -pkg ~/R.pkg -target /
        rm -f ~/R.pkg
        Rscript -e "install.packages(c('tidyverse', 'expss', 'filesstrings', 'foreach', 'doParallel'), force = TRUE, repos = 'https://cloud.r-project.org')"
        check_installed_packages
        exit 0
        ;;
    FreeBSD)
        if grep -q '^ID=freebsd' /etc/os-release 2>/dev/null; then
            sudo pkg upgrade -y && sudo pkg install -y R bwa fastqc fastp samtools bamtools parallel R-cran-tidyverse R-cran-foreach R-cran-doParallel zip
            sudo Rscript -e "install.packages(c('expss', 'filesstrings'), force = TRUE, repos = 'https://cloud.r-project.org')"
            check_installed_packages
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
  conda-forge::r-base \
  conda-forge::r-littler \
  conda-forge::r-tidyverse \
  conda-forge::r-expss \
  conda-forge::r-filesstrings \
  conda-forge::r-foreach \
  conda-forge::r-doparallel \
  conda-forge::parallel \
  bioconda::bwa \
  bioconda::fastqc \
  bioconda::fastp \
  bioconda::samtools \
  bioconda::bamtools

# activate and update ampile
source ~/miniconda3/etc/profile.d/conda.sh
conda activate ampile
R CMD javareconf
conda update --all -y

# check installed packages
check_installed_packages

# deactivate ampile and base
conda deactivate
conda deactivate
