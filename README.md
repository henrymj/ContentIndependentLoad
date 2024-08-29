# Repo for 2 experiments analysing the generalizability of the visual WM load 1.

Experiment 1 compares colors and orientations. Experiment 2 compares colors and motion coherences.

Also see the associated OSF, which contains this repo + the data.

### Breakdown of the repo:  
 - `ExperimentN/` contains the code to run the task in Psychopy (`experiment/`), preprocess the data (`preprocessing/`), and run the analyses related to Experiment N (`analyss/`). Each analysis directory contains another README walking through the specific scripts.
 - `eye_movement_comparisons.ipynb` pools the decodability results across experiments to examine the role of eyemovements in predicting decodability, for figure 8. It calls functions from `eeg_decoder.py` for loading in the data.
 - `env.yml` a minimal requirements file for building a python environment that should be able to run everything...