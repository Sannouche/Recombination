#!/bin/bash

# Check if chromosome argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <chromosome>"
    exit 1
fi

# Input variables
chromosome="$1"
hyperparam_file="02_infos/Hyperparameter_minL2.txt"

# Directory paths
vcf_dir="/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/03_split_vcf/Freshwater_S2_by_chrom/R1"
table_dir="/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/07_make-table_all/Freshwater"
output_dir="/project/lbernatchez/users/sadel35/2025-02-11_Recombination_Pyrho/09_optimize/Freshwater_S2_R1"

# Ensure output directory exists
mkdir -p "$output_dir"

# Extract Block_Penalty and Window_Size for the given chromosome
read block_penalty window_size <<< $(awk -v chr="$chromosome" '$1 == chr {printf "%d %d", $2, $3}' "$hyperparam_file")

# Ensure values were found
if [ -z "$block_penalty" ] || [ -z "$window_size" ]; then
    echo "Error: No hyperparameters found for chromosome $chromosome"
    exit 1
fi

# Define input/output file paths
vcf_file="$vcf_dir/Freshwater_S2_${chromosome}.vcf.gz"
table_file="$table_dir/${chromosome}_freshwater_ds.table"
output_file="${output_dir}/Freshwater_S2_R1_${chromosome}_window${window_size}_bpen${block_penalty}"

# Run pyrho optimize
echo "Running pyrho optimize for $chromosome with Window=$window_size and Block_Penalty=$block_penalty..."

pyrho optimize --vcffile "$vcf_file" --windowsize "$window_size" --blockpenalty "$block_penalty" \
    --tablefile "$table_file" --ploidy 2 --outfile "$output_file" --numthreads 4 \
   --fast_missing