#!/bin/bash

# Calculate hyperparameters
# Run this script from Recombinaison_with_Pyrho directory using :
# parallel -a 02_infos/chromosome_list.txt -k -j 5 srun -c 4 --mem 80G -p medium --time 7-00 -J hyperparam -o 99_log_files/hyperparam_{}.log 01_scripts/05_hyperparameter_pyrho.sh {}&

#VARIABLES
chr=$1
THREADS=4

# Command
pyrho hyperparam --samplesize 88 --decimate_rel_tol 0.1 --tablefile 07_make-table/Saltwater/${chr}_saltwater_ds.table \
--mu 0.00000000456 --ploidy 2 \
--smcpp_file 06_plot_smc++/Saltwater/Saltwater_${chr}_plot.csv  \
--numthreads $THREADS --outfile 08_hyperparameter/${chr}_saltwater_ds.hyperparam
