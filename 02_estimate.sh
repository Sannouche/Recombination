#!/bin/bash
# Calculate historical Ne with SMC++
# Run this script from Genetic_Architecture directory using :
# srun -c 1 --mem 25G -p small -J SMC++_estimate_{} -o 99_log_files/SMC++_estimate.log 01_scripts/02_estimate.sh &


# VARIABLES
chr="II"

#for chr in III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XX XXI; do
    # Your commands here
    echo "Processing chromosome: $chr"
singularity run --bind $HOME /prg/singularity/images/smcpp-1.15.4.sif estimate -o 05_estimate_smc++/Freshwater/Freshwater_chr${chr} 0.456e-8 04_input_smc++/Freshwater/Freshwater_chr${chr}"_"*.smc.gz 

singularity run --bind $HOME /prg/singularity/images/smcpp-1.15.4.sif estimate -o 05_estimate_smc++/Saltwater/Saltwater_chr${chr} 0.456e-8 04_input_smc++/Saltwater/Marine_chr${chr}"_"*.smc.gz

done
