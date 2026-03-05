# Load necessary libraries
library(data.table)
library(dplyr)

# Get command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if the file path is provided
if (length(args) != 1) {
  stop("Please provide the path to the recombination map file.")
}

# Read the recombination map file
input_file <- args[1]
recomb_data <- fread(input_file, header = FALSE)
colnames(recomb_data) <- c("Chromosome", "Start", "End", "MeanRate")

# Transformation log
recomb_data <- recomb_data %>% filter(!is.na(MeanRate))

recomb_data$MeanRate <- log10(as.numeric(recomb_data$MeanRate))


# Main coldspot detection function
detect_coldspots <- function(data) {
  setDT(data)

  # Ensure columns are properly typed
  data[, Chromosome := as.character(Chromosome)]
  data[, Start := as.numeric(Start)]
  data[, End := as.numeric(End)]
  data[, MeanRate := as.numeric(MeanRate)]

  # Create empty lists to collect coldspot rows
  coldspots_40kb <- list()
  coldspots_1Mb <- list()
  coldspots_whole_chr <- list()

  chromosomes <- unique(data$Chromosome)

  for (chr in chromosomes) {
    chr_data <- data[Chromosome == chr]
    chr_mean <- mean(chr_data$MeanRate, na.rm = TRUE)
    chr_sd <- sd(chr_data$MeanRate, na.rm = TRUE)

    for (i in 1:nrow(chr_data)) {
      row <- chr_data[i]
      start_pos <- row$Start
      end_pos <- row$End
      mean_rate <- row$MeanRate

    # Get background data windows
      bg_40kb_data <- data[Chromosome == chr & Start >= (start_pos - 20000) & End <= (end_pos + 20000)]
      bg_1Mb_data <- data[Chromosome == chr & Start >= (start_pos - 500000) & End <= (end_pos + 500000)]

      bg_40kb_mean <- mean(bg_40kb_data$MeanRate, na.rm = TRUE)
      bg_40kb_sd <- sd(bg_40kb_data$MeanRate, na.rm = TRUE)

      bg_1Mb_mean <- mean(bg_1Mb_data$MeanRate, na.rm = TRUE)
      bg_1Mb_sd <- sd(bg_1Mb_data$MeanRate, na.rm = TRUE)

      # Skip if any background is NA
      if (is.na(mean_rate) || is.na(bg_40kb_mean) || is.na(bg_40kb_sd) ||
          is.na(bg_1Mb_mean) || is.na(bg_1Mb_sd) || is.na(chr_mean) || is.na(chr_sd)) next

 # Check thresholds and add rows to respective coldspot lists
      if (mean_rate <= (bg_40kb_mean - 3 * bg_40kb_sd)) {
        coldspots_40kb[[length(coldspots_40kb) + 1]] <- data.table(
          Chromosome = chr, Start = start_pos, End = end_pos, AvgRate = mean_rate, Background = "40kb"
        )
      }
      if (mean_rate <= (bg_1Mb_mean - 3 * bg_1Mb_sd)) {
        coldspots_1Mb[[length(coldspots_1Mb) + 1]] <- data.table(
          Chromosome = chr, Start = start_pos, End = end_pos, AvgRate = mean_rate, Background = "1Mb"
        )
      }
      if (mean_rate <= (chr_mean - 3 * chr_sd)) {
        coldspots_whole_chr[[length(coldspots_whole_chr) + 1]] <- data.table(
          Chromosome = chr, Start = start_pos, End = end_pos, AvgRate = mean_rate, Background = "whole_chromosome"
        )
      }
    }
  }

  # Bind the lists into data.tables
  return(list(
    coldspots_40kb = rbindlist(coldspots_40kb),
    coldspots_1Mb = rbindlist(coldspots_1Mb),
    coldspots_whole_chromosome = rbindlist(coldspots_whole_chr)
  ))
}


# Step 1: Detect coldspots
coldspots <- detect_coldspots(recomb_data)

# Step 2: Generate output file name from the input file name
# Extract the file name without extension
file_name <- tools::file_path_sans_ext(basename(input_file))


# Step 3: Save the coldspots to the output file
fwrite(coldspots$coldspots_40kb, file.path(paste0(file_name, "_coldspots_40kb.txt")), sep = "\t")
fwrite(coldspots$coldspots_1Mb, file.path(paste0(file_name, "_coldspots_1Mb.txt")), sep = "\t")
fwrite(coldspots$coldspots_whole_chromosome, file.path(paste0(file_name, "_coldspots_whole_chr.txt")), sep = "\t")

# Optional: Print the output file name
cat("coldspots saved to:", output_file, "\n")