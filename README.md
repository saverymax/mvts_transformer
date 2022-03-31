# Multivariate Time Series Transformer Framework


This code originally corresponded to the [paper](https://dl.acm.org/doi/10.1145/3447548.3467401): George Zerveas et al. **A Transformer-based Framework for Multivariate Time Series Representation Learning**, in _Proceedings of the 27th ACM SIGKDD Conference on Knowledge Discovery and Data Mining (KDD '21), August 14-18, 2021_.
ArXiV version: https://arxiv.org/abs/2010.02803. 

It has been forked from the original repository for the purpose of adding a forecasting module (discussed briefly in the paper), in addition to the pretraining, regression, and classification utility already available. As work on this project progresses, the forecasting options will be described below.

If you find this code or any of the ideas in the paper useful, please consider citing:
```buildoutcfg
@inproceedings{10.1145/3447548.3467401,
author = {Zerveas, George and Jayaraman, Srideepika and Patel, Dhaval and Bhamidipaty, Anuradha and Eickhoff, Carsten},
title = {A Transformer-Based Framework for Multivariate Time Series Representation Learning},
year = {2021},
isbn = {9781450383325},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3447548.3467401},
doi = {10.1145/3447548.3467401},
booktitle = {Proceedings of the 27th ACM SIGKDD Conference on Knowledge Discovery &amp; Data Mining},
pages = {2114–2124},
numpages = {11},
keywords = {regression, framework, multivariate time series, classification, transformer, deep learning, self-supervised learning, unsupervised learning, imputation},
location = {Virtual Event, Singapore},
series = {KDD '21}
}
```

## Setup

_Instructions refer to Unix-based systems (e.g. Linux, MacOS)._ Note that the following has been altered from the previous implementation to account for forecasting.

`cd mvts_transformer/`

Inside an already *existing* root directory, each experiment will create a time-stamped output directory, which contains
model checkpoints, performance metrics per epoch, predictions per sample, the experiment configuration, log files etc.
The following commands assume that you have created a new root directory inside the project directory like this: 
`mkdir experiments`.

[We recommend creating and activating a `conda` or other Python virtual environment (e.g. `virtualenv`) to 
install packages and avoid conficting package requirements; otherwise, to run `pip`, the flag `--user` or `sudo` privileges will be necessary.]

`pip install -r requirements.txt`

\[Note: Because sometimes newer versions of packages break backward compatibility with previous versions or other packages, instead or `requirements.txt` you can use `failsafe_requirements.txt` to use the versions which have been tested to work with this codebase.\] 

Download dataset files and place them in separate directories, one for regression and one for classification.

Classification: http://www.timeseriesclassification.com/Downloads/Archives/Multivariate2018_ts.zip

Regression: https://zenodo.org/record/3902651#.YB5P0OpOm3s

Forecasting: See https://github.com/saverymax/multi-modal-pollution. 

## Example commands

To see all command options with explanations, run: `python src/main.py --help`

You should replace `$1` below with the name of the desired dataset.
The commands shown here specify configurations intended for `BeijingPM25Quality` for regression and `SpokenArabicDigits` for classification.

_[To obtain best performance for other datasets, use the hyperparameters as given in the Supplementary Material of the paper.
Appropriate downsampling with the option `--subsample_factor` can be often used on datasets with longer time series to speedup training, without significant
performance degradation.]_

The configurations as shown below will evaluate the model on the TEST set periodically during training, and at the end of training.

Besides the console output  and the logfile `output.log`, you can monitor the evolution of performance (after installing tensorboard: `pip install tensorboard`) with:
```bash
tensorboard dev upload --name my_exp --logdir path/to/output_dir
```

## Train models from scratch

### Forecasting

Forecasting utility has been added to this libary. This includes adding a new data for handling air pollution data in Brussels, a ForecastDataset class, the collate function collate_forecast for making batches from ForecastDataset,and a ForecastRunner class.

To finetune the transformer for forecasting...


### Regression

(Note: the loss reported for regression is the Mean Square Error, i.e. without the Root)

```bash
python src/main.py --output_dir path/to/experiments --comment "regression from Scratch" --name $1_fromScratch_Regression --records_file Regression_records.xls --data_dir path/to/Datasets/Regression/$1/ --data_class tsra --pattern TRAIN --val_pattern TEST --epochs 100 --lr 0.001 --optimizer RAdam  --pos_encoding learnable --task regression
```

### Classification

```bash
python src/main.py --output_dir experiments --comment "classification from Scratch" --name $1_fromScratch --records_file Classification_records.xls --data_dir path/to/Datasets/Classification/$1/ --data_class tsra --pattern TRAIN --val_pattern TEST --epochs 400 --lr 0.001 --optimizer RAdam  --pos_encoding learnable  --task classification  --key_metric accuracy
```

## Pre-train models (unsupervised learning through input masking)

Can be used for any downstream task, e.g. regression, classification, imputation.

Make sure that the network architecture parameters of the pretrained model match the parameters of the desired fine-tuned model (e.g. use `--d_model 64` for `SpokenArabicDigits`).

```bash
python src/main.py --output_dir experiments --comment "pretraining through imputation" --name $1_pretrained --records_file Imputation_records.xls --data_dir /path/to/$1/ --data_class tsra --pattern TRAIN --val_ratio 0.2 --epochs 700 --lr 0.001 --optimizer RAdam --batch_size 32 --pos_encoding learnable --d_model 128
```

## Fine-tune pretrained models

Make sure that network architecture parameters (e.g. `d_model`) used to fine-tune a model match the pretrained model.

### Regression
```bash
python src/main.py --output_dir experiments --comment "finetune for regression" --name BeijingPM25Quality_finetuned --records_file Regression_records.xls --data_dir /path/to/Datasets/Regression/BeijingPM25Quality/ --data_class tsra --pattern TRAIN --val_pattern TEST  --epochs 200 --lr 0.001 --optimizer RAdam --pos_encoding learnable --d_model 128 --load_model path/to/BeijingPM25Quality_pretrained/checkpoints/model_best.pth --task regression --change_output --batch_size 128
```

### Classification
```bash
python src/main.py --output_dir experiments --comment "finetune for classification" --name SpokenArabicDigits_finetuned --records_file Classification_records.xls --data_dir /path/to/Datasets/Classification/SpokenArabicDigits/ --data_class tsra --pattern TRAIN --val_pattern TEST --epochs 100 --lr 0.001 --optimizer RAdam --batch_size 128 --pos_encoding learnable --d_model 64 --load_model path/to/SpokenArabicDigits_pretrained/checkpoints/model_best.pth --task classification --change_output --key_metric accuracy
```
