# Define terminal color codes
TEXT_YELLOW <- "\033[1;33m"
TEXT_GREEN  <- "\033[1;32m"
TEXT_RESET  <- "\033[0m"

# notify start
cat("\n", TEXT_YELLOW, "Generating plots...", TEXT_RESET, "\n\n", sep = "")

# load packages
packages <- c("filesstrings", "doParallel", "tidyverse", "foreach", "expss")
for (package in packages) {
  if (!suppressWarnings(suppressPackageStartupMessages(require(package, character.only = TRUE)))) {
    install.packages(package, repos = "https://cloud.r-project.org")
    suppressWarnings(suppressPackageStartupMessages(library(package, character.only = TRUE)))
  }
  message("Loaded package: ", package)
}

# check for mutation rate spreadsheets
mutation_rate_spreadsheets <- list.files("./3.analysis/8.spreadsheets/2.mutation_rates/", pattern = ".mpileup.csv", full.names = TRUE)
if (length(mutation_rate_spreadsheets) == 0) {
  cat("\n", TEXT_YELLOW, "Mutation rate spreadsheets (.mpileup.csv) were not found in ./3.analysis/8.spreadsheets/2.mutation_rates/ folder, please double check.", TEXT_RESET, "\n\n", sep = "")
  Sys.sleep(1)
  quit(status = 1)
}
# set threads for parallel processing
numCores <- min(detectCores(logical = TRUE), 32)

# create folders
dir.create("./3.analysis/9.plots/3.absolute_mut/pdf/", recursive = TRUE, showWarnings = FALSE)
dir.create("./3.analysis/9.plots/3.absolute_mut/png/", recursive = TRUE, showWarnings = FALSE)
dir.create("./3.analysis/9.plots/4.absolute_mut_summary/pdf/", recursive = TRUE, showWarnings = FALSE)
dir.create("./3.analysis/9.plots/4.absolute_mut_summary/png/", recursive = TRUE, showWarnings = FALSE)

# summarize absolute mutation rate
csvs <- list.files(path='./3.analysis/8.spreadsheets/2.mutation_rates', pattern='*.mpileup.csv', full.names = TRUE)
summary <- c("avg_A", "std_A", "avg_C", "std_C", "avg_G", "std_G", "avg_T", "std_T")
max_mut <- c()
for (csv in csvs) {
  
  df <- read.csv(csv, header = TRUE)
  df <- filter(df, !is.na(Mut_percentage))
  df$Mut_percentage[df$Mut_percentage < 0] <- 0
  df$Ref_base <- toupper(df$Ref_base)
  region <- unique(df$Region)
  
  a <- filter(df, Ref_base == "A")
  avg_a <- round(mean(a$Mut_percentage),4)
  std_a <- round(sd(a$Mut_percentage),4)
  c <- filter(df, Ref_base == "C")
  avg_c <- round(mean(c$Mut_percentage),4)
  std_c <- round(sd(c$Mut_percentage),4)
  g <- filter(df, Ref_base == "G")
  avg_g <- round(mean(g$Mut_percentage),4)
  std_g <- round(sd(g$Mut_percentage),4)
  t <- filter(df, Ref_base == "T")
  avg_t <- round(mean(t$Mut_percentage),4)
  std_t <- round(sd(t$Mut_percentage),4)
  summary <- data.frame(summary,c(avg_a, std_a, avg_c, std_c, avg_g, std_g, avg_t, std_t))
  max_mut <- c(max_mut, max(df$Mut_percentage, na.rm = TRUE))
  
}
names <- gsub(".mpileup.csv", "", basename(csvs))
colnames(summary) <- c("Base", names)
summary_long <- pivot_longer(summary, cols = 2:ncol(summary), names_to = "Group", values_to = "Value")
summary_long <- summary %>%
  separate(Base, into = c("stat", "base")) %>%   # Split 'Base' into 'stat' and 'base'
  pivot_longer(-c(stat, base), names_to = "sample", values_to = "value") %>%  # Long format
  pivot_wider(names_from = stat, values_from = value)
colnames(summary_long) <- c("Base", "Group", "Mean", "SD")
unique_groups <- unique(summary_long$Group)
max_mut <- max(max_mut)
colors <- c("A" = "#1F77B4", "C" = "#FF7F0E", "G" = "#2CA02C", "T" = "#D62728")

# plot absolute mutation rate
message("\nPlotting absolute mutation rate...\n")
csvs <- list.files(path='./3.analysis/8.spreadsheets/2.mutation_rates', pattern='*.mpileup.csv', full.names = TRUE)
if (max_mut * 1.2 < 4) {
  max_y <- 4
} else if (max_mut * 1.2 > 10) {
  max_y <- 10
} else {
  max_y <- max_mut * 1.2
}
registerDoParallel(numCores)
invisible(foreach (csv = csvs) %dopar% {
  
  df <- read.csv(csv, header = TRUE)
  df <- filter(df, !is.na(Mut_percentage))
  df$Mut_percentage[df$Mut_percentage < 0] <- 0
  df$Ref_base <- toupper(df$Ref_base)
  region <- unique(df$Region)
  
  filename <- basename(csv)
  filename <- gsub("_", "-", filename)
  filename <- gsub(".mpileup.csv","",filename)
  filename <- paste0(filename, "_", region, "_absolute-mutation-rate")
  
  p <- ggplot(df, aes(x=Position, y=Mut_percentage, fill=Ref_base)) +
    geom_col(width = 0.8) +
    scale_fill_manual(values = colors) +
    scale_x_continuous(breaks = seq(0, max(df$Position), by = 50)) +
    coord_cartesian(ylim = c(0, max_y)) +
    labs(title = filename, x = "Position", y = "Mutation Rate (%)") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  ggsave(paste0("./3.analysis/9.plots/3.absolute_mut/pdf/", filename, ".pdf"), plot = p, width = 15, height = 3, units = "in", dpi = 1200)
  ggsave(paste0("./3.analysis/9.plots/3.absolute_mut/png/", filename, ".png"), plot = p, width = 15, height = 3, units = "in", dpi = 600, bg = "white")
  
  ## notify
  message(paste0("  ", basename(csv), ": absolute mutation rate plotted"))
})

# plot absolute mutation rate summary
max_y <- max(summary_long$Mean + summary_long$SD, na.rm = TRUE)
max_y <- ifelse(max_y * 1.2 < 10, max_y * 1.2, 10)
min_y <- min(summary_long$Mean - summary_long$SD, na.rm = TRUE)
min_y <- ifelse(min_y * 1.2 < 0, min_y * 1.2, -0.5)
if (length(unique_groups) <= 12) {
  
  plot_width <- max(5, length(unique_groups) * 0.8 + 2)
  p <- ggplot(summary_long, aes(x = Group, y = Mean, fill = Base)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.5), width = 0.5) +
    geom_errorbar(
      aes(ymin = Mean - SD, ymax = Mean + SD),
      position = position_dodge(width = 0.5),
      width = 0.2,
      color = "gray75",
      linewidth = 0.25) +
    scale_fill_manual(values = colors) +
    coord_cartesian(ylim = c(min_y, max_y)) +
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
  ggsave("./3.analysis/9.plots/4.absolute_mut_summary/png/absolute_mutation_rate_base_summary.png",
         plot = p, width = plot_width, height = 5, units = "in", dpi = 600, bg = "white")
  
} else {
  
  group_chunks <- split(unique_groups, ceiling(seq_along(unique_groups) / 12))
  plot_index <- 1
  for (chunk in group_chunks) {
    
    chunk_data <- filter(summary_long, Group %in% chunk)
    num_groups <- length(unique(chunk_data$Group))
    plot_width <- max(5, num_groups * 0.8 + 2)
    
    p <- ggplot(chunk_data, aes(x = Group, y = Mean, fill = Base)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.5), width = 0.5) +
      geom_errorbar(
        aes(ymin = Mean - SD, ymax = Mean + SD),
        position = position_dodge(width = 0.5),
        width = 0.2,
        color = "gray75",
        linewidth = 0.25) +
      scale_fill_manual(values = colors) +
      coord_cartesian(ylim = c(min_y, max_y)) +
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
    ggsave(paste0("./3.analysis/9.plots/4.absolute_mut_summary/png/absolute_mutation_rate_base_summary_part", plot_index, ".png"),
           plot = p, width = plot_width, height = 5, units = "in", dpi = 600, bg = "white")
    
    plot_index <- plot_index + 1
  }
}

## notify
message("  All samples: summary of absolute mutation rate plotted")

# notify end
cat("\n", TEXT_GREEN, "Done.", TEXT_RESET, "\n\n", sep = "")

# cleanup
rm(list = ls())
