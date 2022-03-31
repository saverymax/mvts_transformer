#model=$VSC_DATA/thesis/mvts_output/models/BeijingPM25Quality_pretraining_2022-03-10_20-46-27_I1W/checkpoints/model_best.pth 
#--load_model ${model}
source $VSC_DATA/miniconda3/bin/activate mvts
python $VSC_DATA/thesis/mvts_transformer/src/main.py --output_dir $VSC_DATA/thesis/mvts_output/models --comment "BXL regression finetuning" --name BXL_debug_finetuned --records_file Regression_records.xls --data_dir $VSC_DATA/thesis/data/brussels_data/ --data_class bxl --pattern TRAIN --val_pattern TEST --epochs 10 --lr 0.001 --optimizer RAdam --pos_encoding learnable --d_model 128 --task regression --change_output --batch_size 128
