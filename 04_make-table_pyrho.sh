#!/bin/bash

# Make a table to use pyrho using demographic parameters from previous study
# Run this script from Recombinaison_with_Pyrho directory using :
# parallel -a 02_infos/chromosome_list.txt -k -j 5 srun -c 4 --mem 80G -p medium --time 7-00 -J pyrho_make -o 99_log_files/make_table_{}.log 01_scripts/04_make-table_pyrho.sh {} &

#VARIABLES
chr=$1

# Command
pyrho make_table --samplesize 88 --approx --decimate_rel_tol 0.1  --moran_pop_size 110 \
--numthreads 4 --mu 0.00000000456 --outfile 07_make-table_all/Freshwater/${chr}_freshwater_ds.table \
--smcpp_file 06_plot_smc++/Freshwater_V2/Freshwater_${chr}_plot.csv

pyrho make_table --samplesize 88 --approx --decimate_rel_tol 0.1  --moran_pop_size 110 \
--numthreads 4 --mu 0.00000000456 --outfile 07_make-table_all/Saltwater/${chr}_saltwater_ds.table \
--smcpp_file 06_plot_smc++/Saltwater_V2/Saltwater_${chr}_plot.csv