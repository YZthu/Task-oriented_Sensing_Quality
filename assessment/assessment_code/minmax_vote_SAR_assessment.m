function [vote_pra, full_SAR_pra, full_test_mse, full_train_mse] = minmax_vote_SAR_assessment(Acc_M, raw_Met, training_dep, testing_dep)
full_test_Acc =[];
full_train_Acc =[];
full_test_SSQ =[];
full_train_SSQ =[];

full_test_mse =[];
full_train_mse =[];

full_SAR_pra =[];
if size(Acc_M,1)> 1
    all_Acc_M = [Acc_M; mean(Acc_M,1)];
else
    all_Acc_M = Acc_M;
end

for algo_n =1:size(all_Acc_M,1)
    %normalize the factor
    full_train_Met = raw_Met(training_dep,:);
    train_acc = all_Acc_M(algo_n, training_dep);
    %[later_th] = data_driven_threshold_selection_each_factor(full_train_Met, train_acc);
    min_max_th = [min(full_train_Met); max(full_train_Met)];
    [~, fin_Met] = threshold_normalization(raw_Met, min_max_th);
    nor_Met = [fin_Met, ones(size(fin_Met,1),1)];
    
    train_all_Acc_M = all_Acc_M(algo_n, training_dep);

    w0=ones(size(nor_Met,2),1)./size(nor_Met,2);

    SAR_weight = fmincon(@(x)factor_regression(x, nor_Met(training_dep,:), train_all_Acc_M) ,w0,[],[],[], [],[],[]);
    X = lsqminnorm(nor_Met(training_dep,:),train_all_Acc_M');
    %test
    SAR_testing_dep_SSQ_M = nor_Met(testing_dep,:)*SAR_weight; % each row is one algorithm's ssq
    SAR_testing_dep_SSQ_M = SAR_testing_dep_SSQ_M';
    
    SAR_training_dep_SSQ_M = nor_Met(training_dep,:)*SAR_weight;
    SAR_training_dep_SSQ_M = SAR_training_dep_SSQ_M';
    
    test_acc = all_Acc_M(algo_n, testing_dep);
    train_acc = all_Acc_M(algo_n, training_dep);
    

    test_mse = limited_mse(SAR_testing_dep_SSQ_M, test_acc);
    train_mse = limited_mse(SAR_training_dep_SSQ_M, train_acc);
    full_test_mse(algo_n,:) = test_mse;
    full_train_mse(algo_n,:) = train_mse;
    
        current_baseline_training_SSQ = SAR_training_dep_SSQ_M;
        current_baseline_testing_SSQ = SAR_testing_dep_SSQ_M;
    %[~,~, baseline_ttest_test_train_error] = SSQ_accuracy_calculate(...
     %   current_baseline_training_SSQ, all_Acc_M(:, training_dep), current_baseline_testing_SSQ, all_Acc_M(:, testing_dep), 0);
        [test_train_pra, test_test_pra] =  relative_rank_accuracy_eva(current_baseline_training_SSQ,...
            train_acc , current_baseline_testing_SSQ, test_acc);
        full_SAR_pra(algo_n,:) = test_train_pra;
        
        if algo_n > 1 & algo_n ==size(all_Acc_M,1) % average value
            continue;
        end
        full_test_Acc(algo_n,:) = test_acc;
        full_train_Acc(algo_n,:) = train_acc;
        full_test_SSQ(algo_n,:) = SAR_testing_dep_SSQ_M;
        full_train_SSQ(algo_n,:) = SAR_training_dep_SSQ_M;
end
%vote test_train
vote_pra =[];
for test_case=1:size(full_test_Acc,2)
    tmp_test_acc = full_test_Acc(:, test_case);
    tmp_test_SSQ = full_test_SSQ(:, test_case);

    acc_re = full_train_Acc > tmp_test_acc;
    ssq_re = full_train_SSQ > tmp_test_SSQ;

    fin_acc_re = sum(acc_re,1);
    fin_ssq_re = sum(ssq_re,1);
    bool_acc_re = fin_acc_re >=(size(full_test_Acc,1)/2);
    bool_ssq_re = fin_ssq_re >=(size(full_test_Acc,1)/2);

   vote_pra(test_case) = sum(bool_acc_re ==bool_ssq_re)/size(full_train_Acc,2);
end 

vote_test_test_pra =[];
for test_case=1:size(full_test_Acc,2)
    tmp_test_acc = full_test_Acc(:, test_case);
    tmp_test_ssq = full_test_SSQ(:, test_case);
    
    tmp_test_Acc = full_test_Acc;
    tmp_test_SSQ = full_test_SSQ;
    tmp_test_Acc(:,test_case) = [];
    tmp_test_SSQ(:,test_case) = [];

    acc_re = tmp_test_Acc > tmp_test_acc;
    ssq_re = tmp_test_SSQ > tmp_test_ssq;

    fin_acc_re = sum(acc_re,1);
    fin_ssq_re = sum(ssq_re,1);
    bool_acc_re = fin_acc_re >=(size(full_test_Acc,1)/2);
    bool_ssq_re = fin_ssq_re >=(size(full_test_Acc,1)/2);

   vote_test_test_pra(test_case) = (sum(bool_acc_re ==bool_ssq_re)-1)/(size(tmp_test_Acc,2)-1);
end 

end