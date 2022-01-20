function [vote_pra, full_SAR_pra, full_test_mse, full_train_mse, full_test_SSQ,...
    full_train_SSQ,full_test_Acc,full_train_Acc,full_test_gd_mse,final_weight,final_th] = vote_SAR_assessment(Acc_M, raw_Met, training_dep, testing_dep,normalization_flag,full_Acc_M)
full_test_Acc =[];
full_train_Acc =[];
full_test_SSQ =[];
full_train_SSQ =[];

full_test_mse =[];
full_train_mse =[];
full_test_gd_mse =[];


full_SAR_pra =[];
if size(Acc_M,1)> 1
    all_Acc_M = [Acc_M; mean(Acc_M,1)];
else
    all_Acc_M = Acc_M;
end
final_weight =[];
final_th={};
for algo_n =1:size(all_Acc_M,1)
    %normalize the factor
    full_train_Met = raw_Met(training_dep,:);
    train_acc = all_Acc_M(algo_n, training_dep);
    
    full_test_Met = raw_Met(testing_dep,:);
    test_acc = all_Acc_M(algo_n, testing_dep);
    
    weight_flag =0;
    fin_weight = NaN;
    switch normalization_flag
        case 1
            later_th = [min(full_train_Met); max(full_train_Met)];
            [~, fin_Met] = threshold_normalization(raw_Met, later_th);
        case 2
            [later_th] = data_driven_threshold_selection_each_factor(full_train_Met, train_acc);
            [~, fin_Met] = threshold_normalization(raw_Met, later_th);
        case 3
            [later_th] = data_driven_threshold_selection_global(full_train_Met, train_acc);
            [~, fin_Met] = threshold_normalization(raw_Met, later_th);
        case 4
            [later_th] = data_driven_threshold_selection_local(full_train_Met, train_acc);
            [~, fin_Met] = threshold_normalization(raw_Met, later_th);
        case 5
            %[later_th, ~] = data_driven_threshold_selection_gradient_descent(full_train_Met, train_acc);
            [later_th, fin_weight] = data_driven_threshold_selection_our_gd(full_train_Met, train_acc, full_test_Met, test_acc);
            [fin_Met] = sigmoid_normalization(raw_Met, later_th);
            weight_flag = 1;
        case 6
            %[later_th, ~] = data_driven_threshold_selection_gradient_descent(full_train_Met, train_acc);
            [later_th, fin_weight] = data_driven_threshold_selection_part_gd(full_train_Met, train_acc, full_test_Met, test_acc);
            [fin_Met] = sigmoid_normalization(raw_Met, later_th);
            weight_flag = 0;
        case 7
            later_th = [min(full_train_Met); max(full_train_Met)];
            [fin_Met] = sigmoid_normalization(raw_Met, later_th);
            nor_Met = [fin_Met, ones(size(fin_Met,1),1)];
            W_c =zeros(size(training_dep, 2), size(training_dep, 2));
            for dep1=1:size(training_dep,2)-1
                dep1_acc = full_Acc_M(:, training_dep(dep1));
                for dep2=dep1+1:size(training_dep,2)
                    dep2_acc = full_Acc_M(:, training_dep(dep2));
                    acc_error = dep1_acc - dep2_acc;
                    acc_compare_flag =[];
                    for tmp_algo_num=1:size(acc_error,1)
                            if acc_error(tmp_algo_num) > 0
                                acc_compare_flag(tmp_algo_num) =1;
                            else
                                acc_compare_flag(tmp_algo_num) = 0;
                            end
                    end
                    W_c(dep1,dep2) = sum(acc_compare_flag);
                    W_c(dep2,dep1) = size(full_Acc_M,1)- sum(acc_compare_flag);
                end
            end
            %BTL weight
            Aeq=ones(1,size(training_dep,2))*nor_Met(training_dep,:);
            Beq=0;
            w0=ones(size(nor_Met,2),1)./size(nor_Met,2);
            A =[nor_Met(training_dep,:); -1*nor_Met(training_dep,:)];
            b = 100*ones(2*size(training_dep,2),1);
            options = optimoptions('fmincon','Display','off');
            %BTL_weight = fmincon(@(x)l_fun(x, nor_Met(training_dep,:), W_c) ,w0,A,b,Aeq, Beq,[],[],[],options);
            BTL_weight = fmincon(@(x)l_fun(x, nor_Met(training_dep,:), W_c) ,w0,[],[],[], [],[],[],[],options);
            fin_weight = BTL_weight;
            weight_flag =1;
    end

    %[~, fin_Met] = threshold_normalization(raw_Met, later_th);
    nor_Met = [fin_Met, ones(size(fin_Met,1),1)];
    if weight_flag ==0
        train_all_Acc_M = all_Acc_M(algo_n, training_dep);
        w0=ones(size(nor_Met,2),1)./size(nor_Met,2);
        options = optimoptions('fmincon','Display','off');
        SAR_weight = fmincon(@(x)factor_regression(x, nor_Met(training_dep,:), train_all_Acc_M) ,w0,[],[],[], [],[],[],[],options);
    else
        SAR_weight = fin_weight;
    end
    final_weight(:, algo_n) =SAR_weight;
    final_th(algo_n)={later_th};
    %test
    SAR_testing_dep_SSQ_M = nor_Met(testing_dep,:)*SAR_weight; % each row is one algorithm's ssq
    SAR_testing_dep_SSQ_M = SAR_testing_dep_SSQ_M';
    
    SAR_training_dep_SSQ_M = nor_Met(training_dep,:)*SAR_weight;
    SAR_training_dep_SSQ_M = SAR_training_dep_SSQ_M';
    
    if ~isnan(fin_weight)
        test_ssq = nor_Met(testing_dep,:)*fin_weight; % each row is one algorithm's ssq
        test_ssq = test_ssq';

        train_ssq = nor_Met(training_dep,:)*fin_weight;
        train_ssq = train_ssq';
        gd_test_mse = limited_mse(test_ssq, test_acc);
        full_test_gd_mse(algo_n,:) = gd_test_mse;
    end
    
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
        [test_train_pra, ~] =  relative_rank_accuracy_eva(current_baseline_training_SSQ,...
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