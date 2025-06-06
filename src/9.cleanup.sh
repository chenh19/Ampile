#!/bin/bash

# set terminal font color
TEXT_YELLOW=$(tput bold; tput setaf 3)
TEXT_GREEN=$(tput bold; tput setaf 2)
TEXT_RESET=$(tput sgr0)

# cleanup
read -n1 -s -r -p "$(echo -e $TEXT_YELLOW'Would you like delete large intermediate files? [y/n/c]'$TEXT_RESET)"$' \n' choice
case "$choice" in
  y|Y ) # trim
        if ! find "./3.analysis/2.trim/" -maxdepth 1 -type f -name "*.trimmed.fastq.gz" | grep -q .; then
          rm -f ./3.analysis/2.trim/*.trimmed.fastq.gz
          echo -e "" > ./3.analysis/2.trim/large_intermediate_files_deleted.txt
        fi

        # bam
        if ! find "./3.analysis/3.bam/" -maxdepth 1 -type f -name "*.filtered.bam" | grep -q .; then
          rm -f ./3.analysis/3.bam/*.filtered.bam ./3.analysis/3.bam/*.filtered.bam.bai
          echo -e "" > ./3.analysis/3.bam/large_intermediate_files_deleted.txt
        fi

        # mpileup
        if ! find "./3.analysis/4.mpileup/" -maxdepth 1 -type f -name "*.mpileup" | grep -q .; then
          rm -f ./3.analysis/4.mpileup/*.mpileup
          echo -e "" > ./3.analysis/4.mpileup/large_intermediate_files_deleted.txt
        fi

        # Rhistory
        [ -f ./.Rhistory ] && rm -f ./.Rhistory

        echo -e " \n${TEXT_GREEN}Large intermediate files deleted.${TEXT_RESET} \n" && sleep 1
        ;;
  * )   echo -e " \n${TEXT_YELLOW}Large intermediate files retained.${TEXT_RESET} \n" && sleep 1
        ;;
esac
