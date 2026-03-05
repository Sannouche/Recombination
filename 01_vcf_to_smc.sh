#!/bin/bash
# Calculate historical Ne with SMC++
# Run this script from Genetic_Architecture directory using :
# parallel -a 02_infos/Saltwater_StLawrence_name.txt -k -j 5 srun -c 1 --mem 25G -p small -J SMC++_{} -o 99_log_files/SMC++_{}.log 01_scripts/01_vcf_to_smc.sh {} VCF &
# parallel -a 02_infos/Freshwater_StLawrence_name.txt -k -j 5 srun -c 1 --mem 25G -p small -J SMC++_{} -o 99_log_files/SMC++_{}.log 01_scripts/01_vcf_to_smc.sh {} VCF &


# VARIABLES
IND=$1
VCF=$2


for chr in II; do
    # Your commands here
    echo "Processing chromosome: $chr"
  singularity run --bind $HOME /prg/singularity/images/smcpp-1.15.4.sif vcf2smc -c 150000 -d $IND $IND $VCF 04_input_smc++/Saltwater/Marine_chr${chr}"_"$IND.smc.gz chr${chr} Marine:CHAT_55,RIM_15,POC_22,FOR_12,BET_19,BERG_22,IV_53,BERG_53,IV_39,CHAT_31,CHAT_11,KAM_32,BET_28,BERG_14,BET_20,BERG_26,POC_27,FOR_35,POC_18,CHAT_20,BET_40,RIM_42,RIM_33,RIM_19,KAM_39,BERG_25,BET_05,POC_39,IV_20,KAM_04,BET_45,FOR_28,BET_41,IV_44,KAM_21,RIM_09,IV_34,BET_34,KAM_52,FOR_22,POC_07,KAM_10,RIM_59,KAM_16,IV_09,KAM_14,IV_25,CHAT_03,RIM_20,IV_27,FOR_18,FOR_45,POC_44,FOR_40,RIM_14,CHAT_49,BET_35,POC_26,BET_16,POC_19,FOR_46,POC_06,IV_29,BET_22,CHAT_51,IV_38,POC_34,IV_10,BERG_44,KAM_12,BERG_27,FOR_15,RIM_44,FOR_25,BET_36,BERG_30,POC_32,KAM_23,BET_08,BET_07,BET_53,RIM_31,KAM_53,CHAT_32,POC_17,BERG_04,IV_12,IV_40
  
#  singularity run --bind $HOME /prg/singularity/images/smcpp-1.15.4.sif vcf2smc -c 150000 -d $IND $IND $VCF 04_input_smc++/Freshwater/Freshwater_chr${chr}"_"$IND.smc.gz chr${chr} Fluvial:CR_04,CR_08,CR_10,CR_12,CR_13,CR_14,CR_15,CR_16,CR_18,CR_19,CR_20,CR_23,CR_25,CR_27,CR_28,CR_30,CR_32,CR_34,CR_35,CR_38,CR_39,CR_41,CR_44,CR_47,CR_F1,CR_F2,CR_M1,CR_M2,LEV_01,LEV_02,LEV_03,LEV_06,LEV_08,LEV_09,LEV_10,LEV_11,LEV_12,LEV_13,LEV_14,LEV_16,LEV_18,LEV_19,LEV_20,LEV_23,LEV_26,LEV_27,LEV_28,LEV_29,LEV_30,LEV_31,LEV_32,LEV_33,LEV_35,LEV_36,LEV_37,LEV_38,LEV_40,LEV_41,LEV_42,LEV_43,LEV_44,LEV_45,LEV_50,LEV_52,LEV_54,LEV_55,LEV_56,PNF_01,PNF_03,PNF_06,PNF_11,PNF_12,PNF_13,PNF_18,PNF_19,PNF_23,PNF_25,PNF_29,PNF_33,PNF_34,PNF_35,PNF_36,PNF_39,PNF_40,PNF_41,PNF_42,PNF_45,PNF_51,PNF_58

done
