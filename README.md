Task-oriented Vibration Sensing Quality Assessment

This project is the implementation of sensing quality assessment for the structural vibration-based sensing system. 
There are two related publications: [AutoQual: task-oriented structural vibration sensing quality assessment leveraging co-located mobile sensing context](https://link.springer.com/article/10.1007/s42486-021-00073-3) and [Vibration-Based Indoor Human Sensing Quality Reinforcement via Thompson Sampling](https://dl.acm.org/doi/pdf/10.1145/3458648.3460012)

The dataset had published on [Footstep-Induced Floor Vibration Dataset In Different Deployment Environment](https://zenodo.org/record/5571057#.YejsuP7MJEZ)


# Factor Calculation
Footstep factor calculation: './foostep_assessment/local_factor_val/fixed_distance_factor_calculate_all_path.m'
Tennis factor calculation: './tennis_assessment/local_assessment/local_factor_calculate_15_locations.m'

# Sensing task
Footstep detection:'./signal_detection/IMU_groundtruth_footstep_detection.m'
Classification: './assessment/save_normal_footstep_classification_F1_score_to_mat.m' and './assessment/save_normal_footstep_classification_F1_score_to_mat_2extra_sc.m'

# Assessment and Evaluation
Section5 result analysis: './assessment/asessment_code/'
data_driven_training_size_assessment_result.m
data_driven_weight_selection_assessment_result.m
minmax_our_normalization_result.m
compare_two_human_assessment_difference_result.m
minmax_our_normalization_result.m



