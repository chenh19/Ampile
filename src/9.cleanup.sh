#!/bin/bash

# set terminal font color
TEXT_YELLOW=$(tput bold; tput setaf 3)
TEXT_GREEN=$(tput bold; tput setaf 2)
TEXT_RESET=$(tput sgr0)

# cleanup
 read -n1 -s -r -p $'\n'"$(echo -e $TEXT_YELLOW'Would you like delete large intermediate files? [y/n/c]'$TEXT_RESET)"$' \n' choice
case "$choice" in
  y|Y ) # refseq
        [ -d ./3.analysis/1.refseq/ ] && rm -rf ./3.analysis/1.refseq/
  
        # trim
        [ -d ./3.analysis/2.trim/ ] && rm -rf ./3.analysis/2.trim/

        # bam
        [ -d ./3.analysis/3.bam/ ] && rm -rf ./3.analysis/3.bam/

        # mpileup
        [ -d ./3.analysis/4.mpileup/ ] && rm -rf ./3.analysis/4.mpileup/

        # Rhistory
        [ -f ./.Rhistory ] && rm -f ./.Rhistory

        echo -e " \n${TEXT_GREEN}Large intermediate files deleted.${TEXT_RESET} \n" && sleep 1;;
  * )   echo -e " \n${TEXT_YELLOW}Large intermediate files retained.${TEXT_RESET} \n" && sleep 1;;
esac

# notify
echo -e "\n${TEXT_GREEN}All done! You may now proceed to analyze the relative mutation rate.\n${TEXT_RESET} \n"
