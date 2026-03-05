library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(data.table)

# Load data
rec <- fread("final_recombination_combined.tsv")

# Create position ID and 5 Mb window ID
rec <- rec %>%
  mutate(
    pos = paste0(Chr, "_", End / 2),
    window = paste0(Chr, "_", floor(Start / 5e6))  # 5 Mb windows
  )

# Extract group names
all_cols <- colnames(rec)
group_cols <- all_cols[!(all_cols %in% c("Chr", "Start", "End", "pos", "window",
                                         "mean_r_Fresh_S1_Simulated", 
                                         "mean_r_Fresh_S2_Simulated", 
                                         "mean_r_Salt_S1_Simulated", 
                                         "mean_r_Salt_S2_Simulated"))]
group_names <- unique(str_remove(group_cols, "_R[123]$"))

# Create list of dfs per group
group_dfs <- lapply(group_names, function(group) {
  cols <- grep(paste0("^", group, "_R[123]$"), colnames(rec), value = TRUE)
  df_subset <- rec[, c("pos", "window", cols), with = FALSE]
  colnames(df_subset) <- c("pos", "window", "R1", "R2", "R3")
  df_subset
})
names(group_dfs) <- group_names

# Compute Spearman correlations per 5 Mb window between each group pair
group_pairs <- combn(group_names, 2, simplify = FALSE)

corr_by_window <- bind_rows(lapply(group_pairs, function(pair) {
  df1 <- group_dfs[[pair[1]]]
  df2 <- group_dfs[[pair[2]]]

  merged <- inner_join(df1, df2, by = c("pos", "window"), suffix = c("_1", "_2"))

  merged %>%
    group_by(window) %>%
    summarise(
      correlation = {
        x <- cbind(R1_1, R2_1, R3_1)
        y <- cbind(R1_2, R2_2, R3_2)
        # Flatten across all rows in the window for Spearman
        x_vals <- as.vector(as.matrix(across(starts_with("R1_1"):starts_with("R3_1"))))
        y_vals <- as.vector(as.matrix(across(starts_with("R1_2"):starts_with("R3_2"))))
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

# Save to file
fwrite(corr_by_window, "correlation_by_5Mb_window.tsv", sep = "\t")
