# Define terminal color codes
TEXT_YELLOW <- "\033[1;33m"
TEXT_GREEN  <- "\033[1;32m"
TEXT_RESET  <- "\033[0m"

# notify start
cat("\n", TEXT_YELLOW, "Parsing pileup files...", TEXT_RESET, "\n\n", sep = "")

# load packages
packages <- c("parallel", "foreach", "doParallel", "filesstrings")
for (package in packages) {
  if (!suppressPackageStartupMessages(require(package, character.only = TRUE))) {
    install.packages(package, repos = "https://cloud.r-project.org", quiet = TRUE)
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  }
  message("Loaded package: ", package)
}

# Set cpu cores for parallel computing
numCores <- detectCores(all.tests = FALSE, logical = TRUE)

# create folders
if (dir.exists("./3.analysis/8.spreadsheets/")==FALSE){
  dir.create("./3.analysis/8.spreadsheets/")
}
if (dir.exists("./3.analysis/8.spreadsheets/3.mpileup_parse/")==FALSE){
  dir.create("./3.analysis/8.spreadsheets/3.mpileup_parse/")
}

# parse mpileup files
message("\nCalculating mutation rate...\n")
pileup_files <- list.files(path='./3.analysis/4.mpileup', pattern='*.mpileup', full.names = TRUE)
registerDoParallel(numCores)
invisible(foreach(pileup_file = pileup_files, .combine = c) %dopar% {

  ## initialize
  mut_profile <- c("Region,Position,Ref_base,Depth,Mut_count,Mut_percentage")

  ## read the file
  pileup_data <- readLines(pileup_file)
  filename <- paste0("./3.analysis/8.spreadsheets/3.mpileup_parse/", basename(pileup_file), ".csv")

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

# archive output spreadsheetsAdd commentMore actions
message("\nZipping mutation rate spreadsheets...\n")
files_to_zip <- list.files(path = "./3.analysis/8.spreadsheets/3.mpileup_parse/", pattern = "*.mpileup.csv", full.names = TRUE)
zip(zipfile = "./3.analysis/8.spreadsheets/3.mpileup_parse/mpileup_parse.zip", files = files_to_zip, extras = "-j")

# notify end
cat("\n", TEXT_GREEN, "Done.", TEXT_RESET, "\n\n", sep = "")

# cleanup
rm(list = ls())
