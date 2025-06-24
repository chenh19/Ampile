# Define terminal color codes
TEXT_YELLOW <- "\033[1;33m"
TEXT_GREEN  <- "\033[1;32m"
TEXT_RESET  <- "\033[0m"

# notify start
cat("\n", TEXT_YELLOW, "Parsing pileup files...", TEXT_RESET, "\n\n", sep = "")

# load packages
packages <- c("filesstrings", "doParallel", "foreach")
for (package in packages) {
  if (!suppressPackageStartupMessages(require(package, character.only = TRUE))) {
    install.packages(package, repos = "https://cloud.r-project.org")
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  }
  message("Loaded package: ", package)
}

# check for mpileup files
mpileup_files <- list.files("./3.analysis/4.mpileup/", pattern = ".mpileup", full.names = TRUE)
if (length(mpileup_files) == 0) {
  cat("\n", TEXT_YELLOW, "Piled-up reads (.mpileup) were not found in ./3.analysis/4.mpileup/ folder, please double check.", TEXT_RESET, "\n\n", sep = "")
  Sys.sleep(1)
  quit(status = 1)
}

# set threads for parallel processing
numCores <- min(detectCores(logical = TRUE), 32)

# create folders
dir.create("./3.analysis/8.spreadsheets/2.mutation_rates/", recursive = TRUE, showWarnings = FALSE)

# parse mpileup files
message("\nCalculating mutation rate...\n")
pileup_files <- list.files(path='./3.analysis/4.mpileup', pattern='*.mpileup', full.names = TRUE)
registerDoParallel(numCores)
invisible(foreach(pileup_file = pileup_files, .combine = c) %dopar% {

  ## initialize
  mut_profile <- c("Region,Position,Ref_base,Depth,Mut_count,Mut_percentage")

  ## read the file
  pileup_data <- readLines(pileup_file)
  filename <- paste0("./3.analysis/8.spreadsheets/2.mutation_rates/", basename(pileup_file), ".csv")

  ## read each line
  for (line in pileup_data) {

    ### read base info
    fields <- strsplit(line, "\t")[[1]]
    chr <- fields[1]
    pos <- as.integer(fields[2])
    ref_base <- fields[3]
    depth <- as.numeric(fields[4])
    read_bases <- fields[5]

    ### calculate mutation rate
    match <- 0
    for (base in strsplit(read_bases, "")[[1]]) {
      if (base == ".") {
        match <- match + 1
      }
      if (base == ",") {
        match <- match + 1
      }
    }
    mut_count <- depth - match
    mut_percentage <- mut_count / depth * 100
    mut_profile <- c(mut_profile, paste(chr, pos, ref_base, depth, mut_count, round(mut_percentage, 4), sep = ","))
  }

  ### write output spreadsheet
  writeLines(mut_profile, filename)

  ### notify
  message(paste0("  ", basename(pileup_file), ": mutation rate successfully parsed"))
})

# notify end
cat("\n", TEXT_GREEN, "Done.", TEXT_RESET, "\n\n", sep = "")

# cleanup
rm(list = ls())
