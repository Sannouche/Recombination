library(dplyr)
library(readr)

# Load dataset
input_file <- "final_recombination_R1.tsv"
df <- read_tsv(input_file, col_types = cols())

# Force numeric type on recombination rate columns
df$mean_r_Freshwater_S1 <- as.numeric(df$mean_r_Freshwater_S1)
df$mean_r_Freshwater_S2 <- as.numeric(df$mean_r_Freshwater_S2)
df$mean_r_Saltwater_S1 <- as.numeric(df$mean_r_Saltwater_S1)
df$mean_r_Saltwater_S2 <- as.numeric(df$mean_r_Saltwater_S2)

recomb_cols <- c("mean_r_Freshwater_S1", "mean_r_Freshwater_S2", 
                 "mean_r_Saltwater_S1", "mean_r_Saltwater_S2")

# Remove rows where all recombination values are NA
df <- df %>%
  filter(!if_all(all_of(recomb_cols), is.na))

# Sort data by chromosome and start position
df <- df %>% arrange(Chr, Start)


# Function to compute PRDI per window and globally
PRDI_Calculation <- function(data, method_name = "spearman", window_size = 5000000) {
  
  # Initialize correlation storage for global PRDI
  global_within <- c()
  global_between <- c()
  
  result_table <- data.frame()

  # Loop through each chromosome
  chromosomes <- unique(data$Chr)
  
  for (chr in chromosomes) {
    chr_data <- data %>% filter(Chr == chr)
    start_positions <- seq(min(chr_data$Start), max(chr_data$End), by = window_size)
    
    for (window_start in start_positions) {
      window_end <- window_start + window_size - 1
      
      data_subset <- chr_data %>%
        filter(Start >= window_start & End <= window_end)

      # Compute pairwise Spearman correlations
      cor_fw <- cor.test(data_subset$mean_r_Freshwater_S1, data_subset$mean_r_Freshwater_S2, method = method_name)$estimate
      cor_sw <- cor.test(data_subset$mean_r_Saltwater_S1, data_subset$mean_r_Saltwater_S2, method = method_name)$estimate
      
      cor_fw_sw1 <- cor.test(data_subset$mean_r_Freshwater_S1, data_subset$mean_r_Saltwater_S1, method = method_name)$estimate
      cor_fw_sw2 <- cor.test(data_subset$mean_r_Freshwater_S1, data_subset$mean_r_Saltwater_S2, method = method_name)$estimate
      cor_fw2_sw1 <- cor.test(data_subset$mean_r_Freshwater_S2, data_subset$mean_r_Saltwater_S1, method = method_name)$estimate
      cor_fw2_sw2 <- cor.test(data_subset$mean_r_Freshwater_S2, data_subset$mean_r_Saltwater_S2, method = method_name)$estimate
      
      # Store for global PRDI
      global_within <- c(global_within, cor_fw, cor_sw)
      global_between <- c(global_between, cor_fw_sw1, cor_fw_sw2, cor_fw2_sw1, cor_fw2_sw2)
      
      # Calculate PRDI for this window
      PRDI_window <- median(min(cor_fw, cor_sw)) - median(c(cor_fw_sw1, cor_fw_sw2, cor_fw2_sw1, cor_fw2_sw2))

      # Store result
      result_table <- rbind(result_table, data.frame(
        Chr = chr,
        Start = window_start,
        End = window_end,
        FW_S1_vs_S2 = cor_fw,
        SW_S1_vs_S2 = cor_sw,
        FW_S1_vs_SW_S1 = cor_fw_sw1,
        FW_S1_vs_SW_S2 = cor_fw_sw2,
        FW_S2_vs_SW_S1 = cor_fw2_sw1,
        FW_S2_vs_SW_S2 = cor_fw2_sw2,
        PRDI_window = PRDI_window
      ))
    }
  }

  return(list(window_data = result_table))
}

# Run the analysis
result <- PRDI_Calculation(df)

# Export results
write_tsv(result$window_data, "PRDI_window_results.tsv")

# Also save global PRDI separately if needed
writeLines(as.character(result$PRDI_global), "PRDI_global_value.txt")
