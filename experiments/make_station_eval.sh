horizons="1 5 10"
chems="no2 pm10 pm25"
lr="_lre4"
cd generated_experiments/eval
rm run_all_eval_station.sh
for h in $horizons
do
    for c in $chems
    do 
        RUN_DESC="bxl_eval${lr}_station_h-${h}_${c}"
echo $RUN_DESC
MODEL=$VSC_DATA/thesis/mvts_output/models/bxl_finetune${lr}_station_h-${h}_${c}*/checkpoints/model_best.pth
NORM=$VSC_DATA/thesis/mvts_output/models/bxl_finetune${lr}_station_h-${h}_${c}*/normalization.pickle
echo $MODEL
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
    --comment \"generating forecasts on test data with ${RUN_DESC}\" \\
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
    --load_model ${MODEL}" > run_${RUN_DESC}.PBS
        echo "qsub run_${RUN_DESC}.PBS" >> run_all_eval_station.sh
    done
done
