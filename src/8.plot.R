# load packages
packages <- c("tidyverse", "ggplot2", "expss", "filesstrings")
for (package in packages) {
  if (!suppressPackageStartupMessages(require(package, character.only = TRUE))) {
    install.packages(package, repos = "https://cloud.r-project.org", quiet = TRUE)
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  }
  message("Loaded package: ", package)
}

# create folder
if (dir.exists("./3.analysis/8.plot/")==FALSE){
  dir.create("./3.analysis/8.plot/")
}
if (dir.exists("./3.analysis/8.plot/3.absolute_mut")==FALSE){
  dir.create("./3.analysis/8.plot/3.absolute_mut")
}

# plot absolute values
message("\nPlotting absolute mutation rate...\n")
csvs <- list.files(path='./3.analysis/7.parse', pattern='*.mpileup.csv', full.names = TRUE)
for (csv in csvs) {
  
  df <- read.csv(csv, header = TRUE)
  df <- filter(df, !is.na(Mut_percentage))
  df$Mut_percentage[df$Mut_percentage < 0] <- 0
  region <- unique(df$Region)
  
  filename <- gsub("./3.analysis/7.parse/","",csv)
  filename <- gsub("_", "-", filename)
  filename <- gsub(".mpileup.csv","",filename)
  filename <- paste0(filename, "_", region)
  
  p <- ggplot(df, aes(x=Position, y=Mut_percentage, fill=Ref_base)) +
    geom_col(width = 0.8) +
    scale_fill_manual(values = c("a" = "#1F77B4", "c" = "#FF7F0E", "g" = "#2CA02C", "t" = "#D62728")) +
    scale_x_continuous(breaks = seq(0, max(df$Position), by = 50)) +
    coord_cartesian(ylim = c(0, 10)) +
    labs(title = filename, x = "Position", y = "Mutation (%)") +
    theme_minimal() + 
    theme(plot.title = element_text(hjust = 0.5))
  ggsave(paste0("./3.analysis/8.plot/3.absolute_mut/", filename, ".jpg"), plot = p, width = 15, height = 3, units = "in", dpi = 1200)
}
message("\nDone. You may now proceed to analyze the relative mutation rate.\n")

# cleanup
rm(list = ls())
