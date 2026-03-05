#!/bin/bash
# Calculate historical Ne with SMC++
# Run this script using :
# srun -c 1 --mem 25G -p small -J SMC++_estimate -o 99_log/SMC++_estimate.log 01_scripts/02_estimate.sh &


# VARIABLES


for chr in I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XX XXI; do
    # Your commands here
    echo "Processing chromosome: $chr"
singularity run --bind $HOME /prg/singularity/images/smcpp-1.15.4.sif plot 06_plot_smc++/Freshwater_V2/Freshwater_chr${chr}_plot.png -g 1 -c 05_estimate_smc++/Freshwater/Freshwater_chr${chr}/model.final.json
#singularity run --bind $HOME /prg/singularity/images/smcpp-1.15.4.sif plot 06_plot_smc++/Saltwater_V2/Saltwater_chr${chr}_plot.png -g 1 -c 05_estimate_smc++/Saltwater/Saltwater_chr${chr}/model.final.json

done