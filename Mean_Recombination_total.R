# Assuming your dataframe is named df
library(data.table)

df <- fread("/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/final_recombination_combined.tsv")

# Step 1: Identify the replicate columns (excluding simulated)
r2_cols <- grep("^mean_r_.*R[1-3]$", names(df), value = TRUE)

# Step 2: Compute the mean across replicates, using .. to access the variable from the parent environment
df[, mean_r2_across_replicates := rowMeans(.SD, na.rm = TRUE), .SDcols = r2_cols]

# Step 3: Write output if needed
fwrite(df, "/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/Total_Mean_recombination.tsv", sep = "\t")