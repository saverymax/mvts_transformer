python $VSC_DATA/thesis/mvts_transformer/src/main.py --output_dir $VSC_DATA/thesis/mvts_output/models --comment "regression finetuning" --name BeijingPM25Quality_finetuned --records_file $VSC_DATA/thesis/mvts_output/records_xls/Regression_records.xls --data_dir $VSC_DATA/thesis/data/monash_data/BeijingPM25Quality/ --data_class tsra --pattern TRAIN --val_pattern TEST --epochs 10 --lr 0.001 --optimizer RAdam --pos_encoding learnable --d_model 128 --load_model $VSC_DATA/thesis/mvts_output/models/BeijingPM25Quality_pretraining_2022-03-10_20-46-27_I1W/checkpoints/model_best.pth --task regression --change_output --batch_size 128
