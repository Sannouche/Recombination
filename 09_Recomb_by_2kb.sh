#!/bin/bash

# --- CONFIGURATION ---
INPUT_DIR="10_recombination_map"                  # Folder with input .txt files
GENOME_FILE="02_infos/chrEnds.txt"                 # Two-column file: <chr> <length>
WINDOW_SIZE=2000
OUTPUT_DIR="10_recombination_map/By_window"

module load bedtools

# --- LOOP THROUGH ALL .txt FILES IN INPUT DIRECTORY ---
for FILE in "${INPUT_DIR}"/*.txt; do
    BASENAME=$(basename "$FILE" .txt)
    echo "Processing $BASENAME"

    # Step 1: Convert to BED format (skip header, keep chr/start/end/R2)
    awk 'NR>1 {print $1"\t"$3"\t"$4"\t"$5}' "$FILE" > "${OUTPUT_DIR}/${BASENAME}.bed"

    # Step 2: Generate 2 kb windows across the genome
    bedtools makewindows -g "$GENOME_FILE" -w "$WINDOW_SIZE" > "${OUTPUT_DIR}/genome_2kb_windows.bed"

    # Step 3: Map mean R² values to the 2 kb windows
    bedtools map -a "${OUTPUT_DIR}/genome_2kb_windows.bed" \
                 -b "${OUTPUT_DIR}/${BASENAME}.bed" \
                 -c 4 -o mean > "${OUTPUT_DIR}/${BASENAME}_2kb_avg.bed"

    echo "Finished: ${OUTPUT_DIR}/${BASENAME}_2kb_avg.bed"
done

echo "All files processed!"
