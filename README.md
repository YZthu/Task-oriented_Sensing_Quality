# SensingQuality_extended_exp

This project is the implementation of sensing quality assessment for the structural vibratin-based sensing system. There are two related publications: [AutoQual: task-oriented structural vibration sensing quality assessment leveraging co-located mobile sensing context](https://link.springer.com/article/10.1007/s42486-021-00073-3) and [Vibration-Based Indoor Human Sensing Quality Reinforcement via Thompson Sampling](https://dl.acm.org/doi/pdf/10.1145/3458648.3460012)


The dataset contains three excitations:
1.Footstep: two participants, with three types of shoes.
2.Tennis ball drop: stand ard excitations
3.The other 5 kinds of balls: Not used in this implementation.
We have 11 environments in two categorys:
1. 9 environments: contains 4 sensors (6ftX4ft), gain is 60 dB.
2. 2 environments: cross beam, 6 sensors (2fxX2ft), sensor 5 gain is 40 dB, sensor 6 is 80 dB. sensor 5 and sensor 6 is close to sensor 2.

Papre: CCF

mat_dataset: the extracted data from the sensor data. named as 'deployment name'_'footstep/tennis/ball'_'dataset.mat'.
There are 6 subsets of human footsteps: 'P1S1','P1S2','P1S3','P2S1','P2S2','P2S3'.
Factors: 'P1S2' or 'P2S2', the human variation analysis.
Sensing task: 'P1S1','P1S3','P2S1','P2S3', four-class classification.

# Factor
Footstep factor calculation: './foostep_assessment/local_factor_val/fixed_distance_factor_calculate_all_path.m'
Tennis factor calculation: './tennis_assessment/local_assessment/local_factor_calculate_15_locations.m'

# Sensing task
Footstep detection:'./signal_detection/IMU_groundtruth_footstep_detection.m'
Classification: './assessment/save_normal_footstep_classification_F1_score_to_mat.m' and './assessment/save_normal_footstep_classification_F1_score_to_mat_2extra_sc.m'
The implementation is on box, 'normal_footstep_re(CCF)'
The foostep classification data extaction is './footstep_assessment/footstep_mat/normal_footstep_extraction.m' and './footstep_assessment/footstep_mat/save_natural_footstep_to_csv.m'

# Figures in paper
Section5 result analysis: './assessment/asessment_code/'
data_driven_training_size_assessment_result.m
data_driven_weight_selection_assessment_result.m
minmax_our_normalization_result.m
compare_two_human_assessment_difference_result.m
minmax_our_normalization_result.m

Section 3 examples: in the previous 40 deployments repository './tennis_assessment/'


