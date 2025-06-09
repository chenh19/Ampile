# Define terminal color codes
TEXT_YELLOW <- "\033[1;33m"
TEXT_GREEN  <- "\033[1;32m"
TEXT_RESET  <- "\033[0m"

# notify start
cat("\n", TEXT_YELLOW, "Generating plots...", TEXT_RESET, "\n\n", sep = "")

# load packages
packages <- c("tidyverse", "ggplot2", "expss", "filesstrings")
for (package in packages) {
  if (!suppressPackageStartupMessages(require(package, character.only = TRUE))) {
    install.packages(package, repos = "https://cloud.r-project.org", quiet = TRUE)
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  }
  message("Loaded package: ", package)
}

# create folders
if (dir.exists("./3.analysis/9.plots/")==FALSE){
  dir.create("./3.analysis/9.plots/")
}
if (dir.exists("./3.analysis/9.plots/3.absolute_mut/")==FALSE){
  dir.create("./3.analysis/9.plots/3.absolute_mut/")
}
if (dir.exists("./3.analysis/9.plots/3.absolute_mut/pdf/")==FALSE){
  dir.create("./3.analysis/9.plots/3.absolute_mut/pdf/")
}
if (dir.exists("./3.analysis/9.plots/3.absolute_mut/jpg/")==FALSE){
  dir.create("./3.analysis/9.plots/3.absolute_mut/jpg/")
}
if (dir.exists("./3.analysis/9.plots/4.absolute_mut_summary/")==FALSE){
  dir.create("./3.analysis/9.plots/4.absolute_mut_summary/")
}
if (dir.exists("./3.analysis/9.plots/4.absolute_mut_summary/pdf/")==FALSE){
  dir.create("./3.analysis/9.plots/4.absolute_mut_summary/pdf/")
}
if (dir.exists("./3.analysis/9.plots/4.absolute_mut_summary/jpg/")==FALSE){
  dir.create("./3.analysis/9.plots/4.absolute_mut_summary/jpg/")
}

# plot absolute mutation rate
message("\nPlotting absolute mutation rate...\n")
csvs <- list.files(path='./3.analysis/8.spreadsheets/3.mpileup_parse', pattern='*.mpileup.csv', full.names = TRUE)
colors <- c("A" = "#1F77B4", "C" = "#FF7F0E", "G" = "#2CA02C", "U" = "#D62728")
summary <- c("avg_A","avg_C","avg_G","avg_U")
for (csv in csvs) {
  
  df <- read.csv(csv, header = TRUE)
  df <- filter(df, !is.na(Mut_percentage))
  df$Mut_percentage[df$Mut_percentage < 0] <- 0
  df$Ref_base <- toupper(df$Ref_base)
  df$Ref_base <- gsub("T", "U", df$Ref_base)
  region <- unique(df$Region)

  filename <- basename(csv)
  filename <- gsub("_", "-", filename)
  filename <- gsub(".mpileup.csv","",filename)
  filename <- paste0(filename, "_", region, "_absolute-mutation-rate")
  
  a <- filter(df, Ref_base == "A")
  a <- round(mean(a$Mut_percentage),4)
  c <- filter(df, Ref_base == "C")
  c <- round(mean(c$Mut_percentage),4)
  g <- filter(df, Ref_base == "G")
  g <- round(mean(g$Mut_percentage),4)
  u <- filter(df, Ref_base == "U")
  u <- round(mean(u$Mut_percentage),4)
  summary <- data.frame(summary,c(a,c,g,u))
  
  p <- ggplot(df, aes(x=Position, y=Mut_percentage, fill=Ref_base)) +
    geom_col(width = 0.8) +
    scale_fill_manual(values = colors) +
    scale_x_continuous(breaks = seq(0, max(df$Position), by = 50)) +
    coord_cartesian(ylim = c(0, 10)) +
    labs(title = filename, x = "Position", y = "Mutation Rate (%)") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  ggsave(paste0("./3.analysis/9.plots/3.absolute_mut/pdf/", filename, ".pdf"), plot = p, width = 15, height = 3, units = "in", dpi = 1200)
  ggsave(paste0("./3.analysis/9.plots/3.absolute_mut/jpg/", filename, ".jpg"), plot = p, width = 15, height = 3, units = "in", dpi = 1200)
  
  ## notify
  message(paste0("  ", basename(csv), ": absolute mutation rate plotted"))
}

# plot absolute mutation rate summary
colors <- c("avg_A" = "#1F77B4", "avg_C" = "#FF7F0E", "avg_G" = "#2CA02C", "avg_U" = "#D62728")
names <- gsub(".mpileup.csv", "", basename(csvs))
colnames(summary) <- c("Base", names)
summary_long <- pivot_longer(summary, cols = 2:ncol(summary), names_to = "Group", values_to = "Value")
unique_groups <- unique(summary_long$Group)
if (length(unique_groups) <= 12) {
  
  plot_width <- max(5, length(unique_groups) * 0.8 + 2)
  
  p <- ggplot(summary_long, aes(x = Group, y = Value, fill = Base)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.5), width = 0.5) +
    scale_fill_manual(values = colors) +
    coord_cartesian(ylim = c(-0.5, 1)) +
    theme_minimal() +
    labs(title = "Absolute mutation rate summary",
         x = NULL, y = "Mutation Rate (%)") +
    theme(
      plot.title = element_text(hjust = 0.5),
      axis.text.x = element_text(angle = 65, hjust = 1),
      axis.title.x = element_text(margin = margin(t = 10))
    )
  ggsave("./3.analysis/9.plots/4.absolute_mut_summary/pdf/absolute_mutation_rate_base_summary.pdf",
         plot = p, width = plot_width, height = 5, units = "in", dpi = 1200)
  ggsave("./3.analysis/9.plots/4.absolute_mut_summary/jpg/absolute_mutation_rate_base_summary.jpg",
         plot = p, width = plot_width, height = 5, units = "in", dpi = 1200)
  
} else {
  
  group_chunks <- split(unique_groups, ceiling(seq_along(unique_groups) / 12))
  
  plot_index <- 1
  for (chunk in group_chunks) {
    chunk_data <- filter(summary_long, Group %in% chunk)
    num_groups <- length(unique(chunk_data$Group))
    plot_width <- max(5, num_groups * 0.8 + 2)
    
    p <- ggplot(chunk_data, aes(x = Group, y = Value, fill = Base)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.5), width = 0.5) +
      scale_fill_manual(values = colors) +
      coord_cartesian(ylim = c(-0.5, 1)) +
      theme_minimal() +
      labs(title = paste("Absolute mutation rate summary - Part", plot_index),
           x = NULL, y = "Mutation Rate (%)") +
      theme(
        plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 65, hjust = 1),
        axis.title.x = element_text(margin = margin(t = 10))
      )
    
    ggsave(paste0("./3.analysis/9.plots/4.absolute_mut_summary/pdf/absolute_mutation_rate_base_summary_part", plot_index, ".pdf"),
           plot = p, width = plot_width, height = 5, units = "in", dpi = 1200)
    ggsave(paste0("./3.analysis/9.plots/4.absolute_mut_summary/jpg/absolute_mutation_rate_base_summary_part", plot_index, ".jpg"),
           plot = p, width = plot_width, height = 5, units = "in", dpi = 1200)
    
    plot_index <- plot_index + 1
  }
}

## notify
message("  All samples: summary of absolute mutation rate plotted")

# notify end
cat("\n", TEXT_GREEN, "Done.", TEXT_RESET, "\n\n", sep = "")

# cleanup
rm(list = ls())
