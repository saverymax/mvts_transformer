# Script to automatically generate the ablation experiments 
h="1"
c="no2"
var_remove="pm10 pm25 covid tunnels all"
rm $VSC_DATA/thesis/mvts_transformer/experiments/generated_experiments/finetune/run_all_ablation.sh
rm $VSC_DATA/thesis/mvts_transformer/experiments/generated_experiments/eval/run_all_eval_ablation.sh
for v in $var_remove
do 
cd $VSC_DATA/thesis/mvts_transformer/experiments/generated_experiments/finetune
        RUN_DESC_FINE="bxl_finetune_lre4_ablation_${v}_h-${h}_${c}"
echo $RUN_DESC_FINE
echo "#!/usr/bin/env bash
#PBS -N ${RUN_DESC_FINE}
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
    --comment \"ablation runs for ${RUN_DESC_FINE}\" \\
    --name ${RUN_DESC_FINE} \\
    --records_file $VSC_DATA/thesis/mvts_output/records_xls/Forecast_records_${RUN_DESC_FINE}.xls \\
    --data_dir $VSC_DATA/thesis/data/brussels_data/ \\
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
    --remove_var station_int ${v} \\
    --val_ratio=0.1" > run_${RUN_DESC_FINE}.PBS 
        echo "qsub run_${RUN_DESC_FINE}.PBS" >> run_all_ablation.sh
cd $VSC_DATA/thesis/mvts_transformer/experiments/generated_experiments/eval
RUN_DESC_EVAL="bxl_eval_lre4_ablation_${v}_h-${h}_${c}"
echo $RUN_DESC_EVAL
MODEL=$VSC_DATA/thesis/mvts_output/models/${RUN_DESC_FINE}*/checkpoints/model_best.pth
echo $MODEL
NORM=$VSC_DATA/thesis/mvts_output/models/${RUN_DESC_FINE}*/normalization.pickle
echo "#!/usr/bin/env bash
#PBS -N ${RUN_DESC_EVAL}
#PBS -o /data/leuven/346/vsc34628/thesis/mvts_output/job_output/
#PBS -e /data/leuven/346/vsc34628/thesis/mvts_output/job_output/
#PBS -l walltime=00:10:00 
#PBS -l nodes=1:ppn=36
#PBS -l pmem=5gb
#PBS -A default_project
source $VSC_DATA/miniconda3/bin/activate mvts

# Nice to use batch_size of 4 because each station has 4 time series.
python $VSC_DATA/thesis/mvts_transformer/src/main.py \\
    --output_dir $VSC_DATA/thesis/mvts_output/models \\
    --comment \"generating forecasts using ablation model with ${RUN_DESC_EVAL}\" \\
    --name ${RUN_DESC_EVAL} --records_file $VSC_DATA/thesis/mvts_output/records_xls/Forecast_records_${RUN_DESC_EVAL}.xls \\
    --data_dir $VSC_DATA/thesis/multi-modal-pollution/data/mvts_train \\
    --data_class bxl \\
    --d_model 128 \\
    --task forecast \\
    --batch_size 4 \\
    --seed 13 \\
    --horizon ${h} \\
    --pollutant ${c} \\
    --test_only testset \\
    --test_pattern bxl_test \\
    --norm_from ${NORM} \\
    --remove_var station_int ${v} \\
    --load_model ${MODEL}" > run_${RUN_DESC_EVAL}.PBS
echo "qsub run_${RUN_DESC_EVAL}.PBS" >> run_all_eval_ablation.sh
done
