#!/bin/bash

#VARIABLES

input_file="$1"

output_file="${input_file}_merged.bed"

module load bedtools

# Sort the input before merging (bedtools requires sorted BED)
sorted_tmp=$(mktemp)
sort -k1,1 -k2,2n "$input_file" > "$sorted_tmp"

# Run bedtools merge
echo "Merging intervals in $input_file..."
bedtools merge -i "$sorted_tmp" -d 1000 > "$output_file"

# Clean up temp
rm "$sorted_tmp"

echo "? Merged file saved as: $output_file"
