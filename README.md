a-proof-icf-classifier
=============
# Contents
1. [Description](#description)
2. [Input File](#input-file)
3. [Output File](#output-file)
4. [Machine Learning Pipeline](#machine-learning-pipeline)
5. [How to use?](#how-to-use)

# Description
This repository contains a machine learning pipeline that reads a clinical note in Dutch and assigns the functioning level of the patient based on the textual description.

We focus on 9 [WHO-ICF](https://www.who.int/standards/classifications/international-classification-of-functioning-disability-and-health) domains, which were chosen due to their relevance to recovery from COVID-19:

ICF code | Domain | name in repo
---|---|---
b1300 | Energy level | ENR
b140 | Attention functions | ATT
b152 | Emotional functions | STM
b440 | Respiration functions | ADM
b455 | Exercise tolerance functions | INS
b530 | Weight maintenance functions | MBW
d450 | Walking | FAC
d550 | Eating | ETN
d840-d859 | Work and employment | BER

### Functioning Levels
- FAC and INS have a scale of 0-5, where 5 means there is no functioning problem.
- The rest of the domains have a scale of 0-4, where 4 means there is no functioning problem.
- For more information about the levels, refer to the [annotation guidelines](https://github.com/cltl/a-proof-zonmw/tree/main/resources/annotation_guidelines).
- **NOTE**: the values generated by the machine learning pipeline might sometimes be outside of the scale (e.g. 4.2 for ENR); this is normal in a regression model.

# Input file
The input is a csv file with at least one column containing the text (one clinical note per row).

The csv must follow the following specifications:
- sep = ;
- quotechar = "
- encoding = utf-8
- the first row is the header (column names)

See example in [example/input.csv](example/input.csv).

# Output file
The output file is saved in the same location as the input; it has 'output' added to the original file name.

The output file contains the same columns as the input + 9 new columns with the functioning levels per domain.

The functioning levels are generated per row. If a cell is empty, it means that this domain is not discussed in this note (according to the algorithm).

See example in [example/input_output.csv](example/input_output.csv).

# Machine Learning Pipeline
The pipeline includes a multi-label classification model that detects the domains mentioned in a sentence, and 9 regression models that assign a level to sentences in which a specific domain was detected. All models were created by fine-tuning a pre-trained [Dutch medical language model](https://github.com/cltl-students/verkijk_stella_rma_thesis_dutch_medical_langauge_model).

The pipeline includes the following steps:

![ml_pipe drawio](https://user-images.githubusercontent.com/38586487/134154846-32c38fe2-e9c9-4831-962c-c180b39e6928.png)

# How to use?
1. Install Docker: see [here](https://docs.docker.com/desktop/windows/install/) for Windows and [here](https://docs.docker.com/desktop/mac/install/) for macOS.
2. Pull the docker image from [DockerHub](https://hub.docker.com/r/piekvossen/a-proof-icf-classifier) by typing in your command line:
```
$ docker pull piekvossen/a-proof-icf-classifier
```
3. Run the pipeline with the `docker run` command. You need to pass the following arguments:
- `--in_csv`: path to the input csv file
- `--text_col`: name of the text column in the csv

For example -
```
$ docker run piekvossen/a-proof-icf-classifier --in_csv example/input.csv --text_col text
```

Running the docker for the first time, will download the models from huggingface:

https://huggingface.co/CLTL

In total, 10 transformer models will be downloaded, each between 500MB and 1GB. This will take a while. After downloading, the cached models will be used. 

# Cached models
To save the cached models on the local file system, or use them in a different container in a follow-up run, mount the Huggingface cache dir to a local directory. For example:
```bash
docker run -v <local_path_to_cache>:/root/.cache/huggingface/transformers/ piekvossen/a-proof-icf-classifier --in_csv example/input.csv --text_col text
```

To use the cached models in an environment without internet connection, set `TRANSFORMERS_OFFLINE=1` as environment variable (see [Huggingface documentation](https://huggingface.co/transformers/installation.html#offline-mode)). For example:

```bash
docker run -v <local_path_to_cache>:/root/.cache/huggingface/transformers/ -e TRANSFORMERS_OFFLINE=1 piekvossen/a-proof-icf-classifier --in_csv example/input.csv --text_col text
```
