#!/usr/bin/env bash

# check installed packages
[ -d ~/miniconda3/envs/ampile/ ] && source ~/miniconda3/etc/profile.d/conda.sh && conda activate ampile
error=0
check_installed_packages() {
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
    output=$(Rscript -e 'for (pkg in c("tidyverse", "expss", "filesstrings", "foreach", "doParallel")) if (!suppressWarnings(suppressPackageStartupMessages(require(pkg, character.only = TRUE)))) cat("\033[1;33m", "Error: r-", pkg, " is not installed.", "\033[0m", "\n\n", sep = "")' 2>/dev/null)
    if echo "$output" | grep -q "Error:"; then
      echo "  $output" && echo ""
      error=1
    fi
    if (( error )); then
      echo -e "${TEXT_YELLOW}Please setup the workspace and try again.${TEXT_RESET}\n" >&2 && sleep 1
      exit 1
    else
      echo -e "${TEXT_GREEN}Done.${TEXT_RESET}\n" && sleep 1
    fi
    #Rscript -e 'for (pkg in c("tidyverse", "expss", "filesstrings", "foreach", "doParallel")) if (suppressWarnings(suppressPackageStartupMessages(require(pkg, character.only = TRUE)))) message("  - Successfully installed: r-", pkg, "\n") else message("  x Failed to install: r-", pkg, "\n")'
    #printf "\n%sEnvironment setup complete! You may now proceed to run the Ampile pipeline.%s\n\n\n" "$TEXT_GREEN" "$TEXT_RESET"
    #sleep 1
}
check_installed_packages
[ -d ~/miniconda3/envs/ampile/ ] && conda deactivate
