library(data.table)

df <- fread("/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/Total_Mean_recombination.txt")

# Assuming your table is called df
bin_size <- 20000

# Assign each row to a 20kb bin
df[, Start := floor(Start / bin_size) * bin_size]
df[, End := Start + bin_size]

# Aggregate mean R2 per bin
binned_r2 <- df[, .(mean_r2 = mean(mean_r2_across_replicates, na.rm = TRUE)),
                 by = .(Chr, Start, End)]

# Order the result for neatness
setorder(binned_r2, Chr, Start)

# View or export
head(binned_r2)
fwrite(binned_r2, "binned_recombination_20kb.tsv", sep = "\t")