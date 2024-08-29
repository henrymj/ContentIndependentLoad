# Analyses for Experiment 1

### Breakdown of directory:

The following directories are expected for the scripts to be able to run.  

  - `data/` - the preprocessed data, containing the epoched EEG data (X), the trial codes (y), eye movement data, behavior files, artifact indices, and info about the electrodes, etc. Included in the OSF repo, but not the github.  
  - `output/` - saved intermediate files, like classifer scores, to avoid recomputing. Included in the OSF repo, but not the github.
  - `output/figures/` - saved svgs or pngs, for making the final manuscript figures. Not included, but the figures are displayed in the notebooks.


The scripts are numbered in the order of the analyses/figures in the manuscript.

  - `0_behavior_analysis.ipynb` - analyses the behavioral performance for figure 2.
  - `1_plot_erp.ipynb` - produces the average ERPs for figure 3.
  - `2_hyperplane_attended_feature.ipynb` - computes the decodability of attended feature for figure 4.
  - `3_hyerplance_load_across_feature.ipynb` - computes the decodabilty and generalizability of the WM load signal for figure 6.
  - `4_SpatialAttention.ipynb` - computes the decodability of spatial locations for SS1 targets and SS2 distractors, for figure 10.


All of the decodability scripts rely on utility functions in `eeg_decoder.py`. RSA and the spatial attention scripts additionally rely on utility functions in `rsa_utils.ipynb`.  

If you're curious about eye movements, you can check out `eye_movement_QA.ipynb`.