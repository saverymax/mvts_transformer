# Bxl
python ../src/main.py --output_dir $VSC_DATA/thesis/mvts_output --comment "pretraining through imputation" --name Brussels_pretraining --records_file Imputation_records.xls --data_dir $VSC_DATA/thesis/data/brussels_data/ --data_class bxl --pattern TRAIN --val_ratio 0.2 --epochs 5 --lr 0.001 --optimizer RAdam --batch_size 32 --pos_encoding learnable --d_model 128

