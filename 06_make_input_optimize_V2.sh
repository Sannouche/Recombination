#!/bin/bash

# Chrom file
input_directory="/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/08_hyperparameter/"

# Output file
output_file="02_infos/Hyperparameter_minL2.txt"

# Initialize the output file with a header
echo -e "Chromosome\tBlock_Penalty\tWindow_Size\tPearson_Corr_1bp\tPearson_Corr_10kb\tPearson_Corr_100kb\tL2" > "$output_file"

# Loop through each file in the directory
for file in "$input_directory"/*.hyperparam; do
    # Extract chromosome name (everything before the first underscore "_")
    chromosome=$(basename "$file" | cut -d'_' -f1)

    # Find the row with the lowest L2 value (12th column)
    lowest_L2_row=$(awk 'NR > 1 { if ($12 < min || NR == 2) { min = $12; row = $0 } } END { print row }' "$file")

    # Extract the relevant columns
    block_penalty=$(echo "$lowest_L2_row" | awk '{print $1}')
    window_size=$(echo "$lowest_L2_row" | awk '{print $2}')
    pearson_corr_1bp=$(echo "$lowest_L2_row" | awk '{print $3}')
    pearson_corr_10kb=$(echo "$lowest_L2_row" | awk '{print $4}')
    pearson_corr_100kb=$(echo "$lowest_L2_row" | awk '{print $5}')
    L2=$(echo "$lowest_L2_row" | awk '{print $12}')

    # Append results to the output file
    echo -e "$chromosome\t$block_penalty\t$window_size\t$pearson_corr_1bp\t$pearson_corr_10kb\t$pearson_corr_100kb\t$L2" >> "$output_file"
done