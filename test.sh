#!/usr/bin/env bash

# Check if arrays are supported (Bash or Zsh), fallback to string splitting
check_installed_packages() {
    TEXT_GREEN="$(tput bold)$(tput setaf 2)"
    TEXT_RESET="$(tput sgr0)"
    printf "\nChecking packages:\n\n"

    # Portable string list
    required_tools_str="R bwa fastqc fastp samtools bamtools parallel"

    for tool in $required_tools_str; do
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
check_installed_packages
