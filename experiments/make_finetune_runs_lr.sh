# Script to automatically generate the experiments I want to run
horizons="1 5 10"
chems="no2 pm10 pm25"
cd generated_experiments/finetune
rm run_all_finetune_lr.sh
for h in $horizons
do
    for c in $chems
    do 
        RUN_DESC="bxl_finetune_lre5_no_station_h-${h}_${c}"
echo $RUN_DESC
echo "#!/usr/bin/env bash
#PBS -N ${RUN_DESC}
#PBS -o /data/leuven/346/vsc34628/thesis/mvts_output/job_output/
#PBS -e /data/leuven/346/vsc34628/thesis/mvts_output/job_output/
#PBS -l walltime=03:00:00 
#PBS -l nodes=1:ppn=9:gpus=1:skylake 
#PBS -l partition=gpu 
#PBS -l pmem=5gb 
#PBS -A default_project
source $VSC_DATA/miniconda3/bin/activate mvts; source $VSC_DATA/wandb_info.sh; wandb login;
python $VSC_DATA/thesis/mvts_transformer/src/main.py \\
    --output_dir $VSC_DATA/thesis/mvts_output/models \\
    --comment \"no pretrained finetuning for ${RUN_DESC}\" \\
    --name ${RUN_DESC} \\
    --records_file $VSC_DATA/thesis/mvts_output/records_xls/Forecast_records_${RUN_DESC}.xls \\
    --data_dir $VSC_DATA/thesis/multi-modal-pollution/data/mvts_train \\
    --data_class bxl \\
    --epochs 10000 \\
    --lr 0.00001 \\
    --optimizer RAdam \\
    --pos_encoding learnable \\
    --d_model 128 \\
    --task forecast \\
    --change_output \\
    --batch_size 16 \\
    --seed 13 \\
    --horizon ${h} \\
    --pollutant ${c} \\
    --use_wandb \\
    --remove_var station_int \\
    --val_ratio=0.1" > run_${RUN_DESC}.PBS 
        echo "qsub run_${RUN_DESC}.PBS" >> run_all_finetune_lr.sh
        RUN_DESC="bxl_finetune_lre4_no_station_h-${h}_${c}"
echo $RUN_DESC
echo "#!/usr/bin/env bash
#PBS -N ${RUN_DESC}
#PBS -o /data/leuven/346/vsc34628/thesis/mvts_output/job_output/
#PBS -e /data/leuven/346/vsc34628/thesis/mvts_output/job_output/
#PBS -l walltime=02:00:00 
#PBS -l nodes=1:ppn=9:gpus=1:skylake 
#PBS -l partition=gpu 
#PBS -l pmem=5gb 
#PBS -A default_project
source $VSC_DATA/miniconda3/bin/activate mvts; source $VSC_DATA/wandb_info.sh; wandb login;
python $VSC_DATA/thesis/mvts_transformer/src/main.py \\
    --output_dir $VSC_DATA/thesis/mvts_output/models \\
    --comment \"no pretrained finetuning for ${RUN_DESC}\" \\
    --name ${RUN_DESC} \\
    --records_file $VSC_DATA/thesis/mvts_output/records_xls/Forecast_records_${RUN_DESC}.xls \\
    --data_dir $VSC_DATA/thesis/multi-modal-pollution/data/mvts_train \\
    --data_class bxl \\
    --epochs 10000 \\
    --lr 0.0001 \\
    --optimizer RAdam \\
    --pos_encoding learnable \\
    --d_model 128 \\
    --task forecast \\
    --change_output \\
    --batch_size 16 \\
    --seed 13 \\
    --horizon ${h} \\
    --pollutant ${c} \\
    --use_wandb \\
    --remove_var station_int \\
    --val_ratio=0.1" > run_${RUN_DESC}.PBS 
        echo "qsub run_${RUN_DESC}.PBS" >> run_all_finetune_lr.sh

    done
done
