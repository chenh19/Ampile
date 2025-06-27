#!/usr/bin/env bash

# check installed packages
[ -d ~/miniconda3/envs/ampile/ ] && source ~/miniconda3/etc/profile.d/conda.sh && conda activate ampile
error=0
check_installed_packages() {
    TEXT_YELLOW="$(tput bold)$(tput setaf 3)"
    TEXT_GREEN="$(tput bold)$(tput setaf 2)"
    TEXT_RESET="$(tput sgr0)"
    printf "\nChecking packages:\n\n"
    required_tools=("R" "bwa" "fastqc" "fastp" "samtools" "bamtools" "parallel")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf "  - Successfully installed: %s\n\n" "$tool"
        else
            printf "  x Failed to install: %s\n\n" "$tool"
            error=1
        fi
    done
    output=$(Rscript -e 'pkgs <- c("tidyverse", "expss", "filesstrings", "foreach", "doParallel"); failed <- FALSE; for (pkg in pkgs) { if (suppressWarnings(suppressPackageStartupMessages(require(pkg, character.only = TRUE)))) { message("  - Successfully installed: r-", pkg, "\n") } else { message("  x Failed to install: r-", pkg, "\n"); failed <- TRUE } }; if (failed) quit(status=1)'); r_exit=$?; [[ $r_exit -ne 0 ]] && error=1
    if (( error )); then
      printf "\n%sEnvironment not ready. Please set up the environment and try again.%s\n\n\n" "$TEXT_YELLOW" "$TEXT_RESET" && sleep 1
    else
      printf "\n%sEnvironment setup complete! You may now proceed to run the Ampile pipeline.%s\n\n\n" "$TEXT_GREEN" "$TEXT_RESET" && sleep 1
    fi
}
check_installed_packages
[ -d ~/miniconda3/envs/ampile/ ] && conda deactivate
