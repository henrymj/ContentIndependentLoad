# Repo for Jones, Thyer, Suplica & Awh, 2024 - Cortically disparate visual features evoke content-independent load signals during storage in working memory

Experiment 1 compares colors and orientations. Experiment 2 compares colors and motion coherences.

The [Github](https://github.com/henrymj/ContentIndependentLoad) contains the code. The [OSF](https://osf.io/q8fya/) contains the code + data.

### Breakdown of the repo:  
 - `ExperimentN/` contains the code to run the task in Psychopy (`experiment/`), preprocess the data (`preprocessing/`), and run the analyses related to Experiment N (`analyss/`). Each analysis directory contains another README walking through the specific scripts.
 - `eye_movement_comparisons.ipynb` pools the decodability results across experiments to examine the role of eyemovements in predicting decodability, for figure 8. It calls functions from `eeg_decoder.py` for loading in the data.
 - `env.yml` a minimal requirements file for building a python environment that should be able to run everything...