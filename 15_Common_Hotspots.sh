#!/bin/bash

# Usage: ./intersect_hotspot_categories.sh /path/to/folder

folder="$1"

module load bedtools

# Loop over categories
for category in 1Mb 40kb whole_chr; do
  echo "?? Processing category: $category"

  # Collect file groups
  fw_files=($(ls "$folder"/Freshwater*_hotspots_"${category}".bed_merged.bed 2>/dev/null))
  sw_files=($(ls "$folder"/Saltwater*_hotspots_"${category}".bed_merged.bed 2>/dev/null))
  all_files=("${fw_files[@]}" "${sw_files[@]}")

  # Debug: show the files found
  echo "?? Freshwater files (${#fw_files[@]}):"
  for f in "${fw_files[@]}"; do echo "  - $f"; done

  echo "?? Saltwater files (${#sw_files[@]}):"
  for f in "${sw_files[@]}"; do echo "  - $f"; done

  #######################
  # Function: intersect all files in a list
  #######################
  intersect_all() {
    local files=("$@")
    local tmp=$(mktemp)
    cp "${files[0]}" "$tmp"

    for ((i = 1; i < ${#files[@]}; i++)); do
      local next_tmp=$(mktemp)
      bedtools intersect -a "$tmp" -b "${files[$i]}" > "$next_tmp"
      rm -f "$tmp"
      tmp="$next_tmp"
    done

    cat "$tmp"
    rm -f "$tmp"
  }

  # Freshwater
  if [[ ${#fw_files[@]} -gt 1 ]]; then
    echo "?? Intersecting Freshwater files..."
    intersect_all "${fw_files[@]}" > "$folder/hotspots_${category}_FW_common.bed"
  fi

  # Saltwater
  if [[ ${#sw_files[@]} -gt 1 ]]; then
    echo "?? Intersecting Saltwater files..."
    intersect_all "${sw_files[@]}" > "$folder/hotspots_${category}_SW_common.bed"
  fi

  # All
  if [[ ${#all_files[@]} -gt 1 ]]; then
    echo "?? Intersecting All files..."
    intersect_all "${all_files[@]}" > "$folder/hotspots_${category}_ALL_common.bed"
  fi

  echo "? Done for category $category"
done

echo "?? All permissive intersections complete."
