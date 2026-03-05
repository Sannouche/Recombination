# Load required library
library(dplyr)
library(data.table)

# Define file names and replicate IDs
files <- list(
  R1 = "final_recombination_R1.tsv",
  R2 = "final_recombination_R2.tsv",
  R3 = "final_recombination_R3.tsv"
)

# Function to read and rename columns with replicate info
read_and_rename <- function(file, rep_id) {
  df <- read.delim(file, stringsAsFactors = FALSE)
  colnames(df)[4:7] <- paste0(c("mean_r_Fresh_S1_", "mean_r_Fresh_S2_", 
                                "mean_r_Salt_S1_", "mean_r_Salt_S2_"), rep_id)
  return(df)
}

# Read and rename each replicate
df_list <- mapply(read_and_rename, files, names(files), SIMPLIFY = FALSE)

# Combine all by common columns: Chr, Start, End
combined <- df_list$R1[, 1:3] %>% 
  bind_cols(
    df_list$R1[, 4:7],
    df_list$R2[, 4:7],
    df_list$R3[, 4:7]
  )

# Add simulations
Fresh_S1 <- fread("/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/10_recombination_map/By_window/Freshwater_S1_Simulated_allchr_2kb_avg.bed")
colnames(Fresh_S1) <- c("Chr", "Start", "end", "mean_r_Fresh_S1_Simulated")

Fresh_S2 <- fread("/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/10_recombination_map/By_window/Freshwater_S2_Simulated_allchr_2kb_avg.bed")
colnames(Fresh_S2) <- c("Chr", "Start", "end", "mean_r_Fresh_S2_Simulated")

Salt_S1 <- fread("/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/10_recombination_map/By_window/Saltwater_S1_Simulated_allchr_2kb_avg.bed")
colnames(Salt_S1) <- c("Chr", "Start", "end", "mean_r_Salt_S1_Simulated")

Salt_S2 <- fread("/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/10_recombination_map/By_window/Saltwater_S2_Simulated_allchr_2kb_avg.bed")
colnames(Salt_S2) <- c("Chr", "Start", "end", "mean_r_Salt_S2_Simulated")

combined_V2 <- combined %>%
  left_join(Fresh_S1 %>% select(Chr, Start, mean_r_Fresh_S1_Simulated), by = c("Chr", "Start")) %>%
  left_join(Salt_S1 %>% select(Chr, Start, mean_r_Salt_S1_Simulated), by = c("Chr", "Start")) %>%
  left_join(Fresh_S2 %>% select(Chr, Start, mean_r_Fresh_S2_Simulated), by = c("Chr", "Start")) %>%
  left_join(Salt_S2 %>% select(Chr, Start, mean_r_Salt_S2_Simulated), by = c("Chr", "Start"))

# Save to file
write.table(combined_V2, "final_recombination_combined.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
