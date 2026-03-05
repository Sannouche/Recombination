#!/bin/bash

# Output file
output="Freshwater_S1_R3_allchr.txt"

# Write header to output file
echo -e "chr\twindow_size\tstart\tend\tR2" > "$output"

# Loop through each chromosome listed in chromosome_list.txt
while read -r chr; do
    for size in 30 90; do
        file="09_optimize/Freshwater_S1_R3/Freshwater_S1_R3_${chr}_window${size}_bpen15"

        # Check if file exists before processing
        if [[ -f "$file" ]]; then
            # Append data to output, adding chromosome name and window size
            awk -v chr="$chr" -v size="$size" '{print chr, size, $1, $2, $3}' OFS='\t' "$file" >> "$output"
        else
            echo "Warning: File $file not found, skipping."
        fi
    done
done < 02_infos/chromosome_list.txt

echo "Concatenation complete: $output"