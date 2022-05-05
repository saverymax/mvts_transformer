# Script to generate experiments in which j
horizons="0 1"
chems="no2 pm10 pm25"
cd generated_experiments/eval
rm run_all_forecast_eval.sh
for h in $horizons
do
    for c in $chems
    do 
        RUN_DESC="bxl_eval_lre4_forecast_mask_h-${h}_${c}"
MODEL=$VSC_DATA/thesis/mvts_output/models/bxl_finetune_lre4_forecast_mask_h-${h}_${c}*/checkpoints/model_best.pth
NORM=$VSC_DATA/thesis/mvts_output/models/bxl_finetune_lre4_forecast_mask_h-${h}_${c}*/normalization.pickle
echo $RUN_DESC
echo "#!/usr/bin/env bash
#PBS -N ${RUN_DESC}
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
    --comment \"eval with forecast mask with ${RUN_DESC}\" \\
    --name ${RUN_DESC} --records_file $VSC_DATA/thesis/mvts_output/records_xls/Forecast_records_${RUN_DESC}.xls \\
    --data_dir $VSC_DATA/thesis/multi-modal-pollution/data/mvts_train \\
    --data_class bxl \\
    --d_model 128 \\
    --task forecast \\
    --batch_size 4 \\
    --seed 13 \\
    --horizon ${h} \\
    --pollutant ${c} \\
    --test_only testset \\
    --norm_from ${NORM} \\
    --test_pattern bxl_test \\
    --remove_var station_int \\
    --load_model ${MODEL}" > run_${RUN_DESC}.PBS
        echo "qsub run_${RUN_DESC}.PBS" >> run_all_forecast_eval.sh
RUN_DESC="bxl_eval_lre4_forecast_mask_none_h-${h}_${c}"
MODEL=$VSC_DATA/thesis/mvts_output/models/bxl_finetune_lre4_forecast_mask_none_h-${h}_${c}*/checkpoints/model_best.pth
NORM=$VSC_DATA/thesis/mvts_output/models/bxl_finetune_lre4_forecast_mask_none_h-${h}_${c}*/normalization.pickle
echo $RUN_DESC
echo "#!/usr/bin/env bash
#PBS -N ${RUN_DESC}
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
    --comment \"eval without forecast mask with ${RUN_DESC}\" \\
    --name ${RUN_DESC} --records_file $VSC_DATA/thesis/mvts_output/records_xls/Forecast_records_${RUN_DESC}.xls \\
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
    --no_causal_mask \\
    --remove_var station_int \\
    --load_model ${MODEL}" > run_${RUN_DESC}.PBS
        echo "qsub run_${RUN_DESC}.PBS" >> run_all_forecast_eval.sh
    done
done
