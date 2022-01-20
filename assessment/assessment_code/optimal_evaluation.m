function [SAR_relative_rank_acc, SAR_weight, test_mse, train_mse,SAR_training_dep_SSQ_M,...
    SAR_testing_dep_SSQ_M,SAR_relative_rank_acc_10] = ...
    optimal_evaluation(SAR_weight,all_Acc_M, nor_Met, training_dep, testing_dep)


    %test
    SAR_testing_dep_SSQ_M = nor_Met(testing_dep,:)*SAR_weight; % each row is one algorithm's ssq
    SAR_testing_dep_SSQ_M = SAR_testing_dep_SSQ_M';
    
    SAR_training_dep_SSQ_M = nor_Met(training_dep,:)*SAR_weight;
    SAR_training_dep_SSQ_M = SAR_training_dep_SSQ_M';
    
    test_acc = all_Acc_M(testing_dep);
    train_acc = all_Acc_M(training_dep);
    
    test_mse = limited_mse(SAR_testing_dep_SSQ_M, test_acc);
    train_mse = limited_mse(SAR_training_dep_SSQ_M, train_acc);
    
        current_baseline_training_SSQ = SAR_training_dep_SSQ_M;
        current_baseline_testing_SSQ = SAR_testing_dep_SSQ_M;
    %[~,~, baseline_ttest_test_train_error] = SSQ_accuracy_calculate(...
     %   current_baseline_training_SSQ, all_Acc_M(:, training_dep), current_baseline_testing_SSQ, all_Acc_M(:, testing_dep), 0);
        [SAR_relative_rank_acc, SAR_relative_rank_acc_10] =  relative_rank_accuracy_eva(current_baseline_training_SSQ,...
            mean(all_Acc_M(:, training_dep),1) , current_baseline_testing_SSQ, mean(all_Acc_M(:, testing_dep),1));
        
    
end