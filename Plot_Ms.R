library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(data.table)

# Load and preprocess
rec <- fread("final_recombination_combined.tsv") %>%
  mutate(pos = paste0(Chr, "_", End / 2))

rec$mean_r_Fresh_S1_Simulated <- as.numeric(rec$mean_r_Fresh_S1_Simulated)
rec$mean_r_Fresh_S2_Simulated <- as.numeric(rec$mean_r_Fresh_S2_Simulated)
rec$mean_r_Salt_S1_Simulated <- as.numeric(rec$mean_r_Salt_S1_Simulated)
rec$mean_r_Salt_S2_Simulated <- as.numeric(rec$mean_r_Salt_S2_Simulated)

# --- Keep only the simulated columns ---
simulated_cols <- c("mean_r_Fresh_S1_Simulated", 
                    "mean_r_Fresh_S2_Simulated", 
                    "mean_r_Salt_S1_Simulated", 
                    "mean_r_Salt_S2_Simulated")

# Filter to keep only the relevant columns
rec_sim <- rec[, c("Chr", "Start", "End", "pos", simulated_cols), with = FALSE]

# Create window ID (5 Mb windows) before creating the group_dfs list
rec_sim <- rec_sim %>%
  mutate(window = paste0(Chr, "_", floor(Start / 5e6)))  # 5 Mb windows

# Create list of dfs per group (grouped by simulated columns)
group_dfs <- lapply(simulated_cols, function(group) {
  df_subset <- rec_sim[, c("pos", "Start", "End", "window", group), with = FALSE]
  colnames(df_subset) <- c("pos", "Start", "End", "window", "rate")
  df_subset
})
names(group_dfs) <- simulated_cols

# Get group pairs
group_pairs <- combn(simulated_cols, 2, simplify = FALSE)

# Compute Spearman correlations per 5 Mb window
corr_by_window <- bind_rows(lapply(group_pairs, function(pair) {
  df1 <- group_dfs[[pair[1]]]
  df2 <- group_dfs[[pair[2]]]

  # Merge the two dataframes by position
  merged <- inner_join(df1, df2, by = c("pos","window"), suffix = c("_1", "_2"))

  merged %>%
    group_by(window) %>%
    summarise(
      correlation = {
        # Prepare the data for correlation calculation
        x_vals <- merged$rate_1
        y_vals <- merged$rate_2

        # Compute Spearman correlation
        if (sum(complete.cases(x_vals, y_vals)) >= 5) {
          cor(x_vals, y_vals, method = "spearman", use = "complete.obs")
        } else {
          NA_real_
        }
      },
      .groups = "drop"
    ) %>%
    mutate(comparison = paste(pair[1], "vs", pair[2]))
}))

# Save the result
fwrite(corr_by_window, "correlation_by_5Mb_window_simulated.tsv", sep = "\t")
