clear;
close all;
clc;

addpath('../')

support_sc = [1,2,3,4,5,6,7,8,9,10,11];
%sig_detection accuracy
%[sig_detection_acc] = sig_detection_accuracy_read('../', support_sc);
[detection_F1_score, detection_tp] = new_sig_detection_accuracy_read('../', support_sc);
%classification accuracy

classification_accuracy = classification_accuracy_read('../');

classification_accuracy(5,:) =[];%remove Adaboost
max_classification_accuracy = classification_accuracy;
mean_class = mean(classification_accuracy([1,2,3,4,6,7,8],:));
max_classification_accuracy = [max_classification_accuracy; mean_class];

%max_classification_accuracy = detection_F1_score;

exc_name =["tennis", "footstep"];
app_name =["cl", "sd", "sd_tp"];
h=waitbar(0,'please wait');

load('test_training_set.mat');


%factor_set
%factor_combine_set={[1,2,3,4,5,6,7,8]};
%random factor
%load('rand_f.mat')

%train_dep_number = [8, 12, 16, 20, 24];
train_dep_number = [24];

for excitation_num=1:2 % 1 tennis 2 footstep
for app_num=1:2     % 1 cl classification 2 sd f1 

  
    test_number= 4;

    switch app_num
        case 1
            all_Acc_M = max_classification_accuracy;
            algorithm_number = 8+1;
        case 2
            all_Acc_M = detection_F1_score;
            algorithm_number = 1;
    end


    % local factor read
    % concentrate band scale selectio

    full_test_st = test_set_4;
    for train_num= 1:length(train_dep_number)
        
        %{
    if excitation_num == 1 % tennis
        [ABRH_Met, bandwidth_Met, SNR, SSIM,~] = tennis_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, ~, ~, new_ECB_fa] = rand_single_exc_tennis_factor_generate('../', support_sc);
    else
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = footstep_factor_generate('../',support_sc);
        %[~, ~, SNR, SSIM, ~, ~] = footstep_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, ~, ~, new_ECB_fa] = rand_single_exc_footstep_factor_generate('../',support_sc);
    end
    factor_M =[ABRH_Met, bandwidth_Met];
    selected_factor =[1:4, 2+18+4, 6+18+4, 10+18+4];
    ene_set = 0;
    selected_factor =[1:4, 2+ene_set+4, 5+ene_set+4, 10+ene_set+4];
    new_factor_M = factor_M(:, selected_factor);
    
    %new_factor_M = [ABRH_Met, new_ECB_fa];

    raw_Met = new_factor_M;
    raw_SNR = SNR;
    raw_SSIM = SSIM;
       %}
        train_number = train_dep_number(train_num);
        eval(['full_train_st = train_set_', num2str(train_number), ';']);
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), '_nor_less.mat'];% minmax/nor %multi/less
        
        save(mat_file_name, 'full_train_st', 'full_test_st');
        
        waitbar(train_num / length(train_dep_number), h, ['exc ', num2str(excitation_num),...
           ' app ', num2str(app_num), ' case ', num2str(train_num)]);
                
        train_case_number = 200;%size(full_train_st,1);
        tmp_result = cell(train_case_number, algorithm_number);
        pre_re = zeros(1, train_case_number);
        parfor train_case_num=1:train_case_number 

    if excitation_num == 1 % tennis
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse] = tennis_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse] = rand_single_exc_tennis_factor_generate('../', support_sc);
    else
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse] = footstep_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse] = rand_single_exc_footstep_factor_generate('../',support_sc);
    end
  
    %new_factor_M = [ABRH_Met, new_ECB_fa, bck_pse', sig_pse',sig_pse'-bck_pse'];
    new_factor_M = [ABRH_Met, new_ECB_fa];
    all_raw_Met = new_factor_M;
    raw_SNR = nanmean(SNR,2);
    raw_SSIM = nanmean(SSIM,2);
    
    
    
            full_train_dep = full_train_st(train_case_num,:);
            %full_test_dep = full_test_st(train_case_num,:);
            full_test_dep = 1:size(all_raw_Met,1);
            full_test_dep(full_train_dep) = [];

            all_SSQ_train=[];
            all_SSQ_test =[];

    for tmp_algo_num=1:algorithm_number           
            % sensor environment layer
            %{
            ECB_fa = all_raw_Met(:,6:8);
            pse_fa = all_raw_Met(:,9:end);
            dep_fa =[ ECB_fa, pse_fa];
            dep_off_met = [dep_fa, ones(size(dep_fa,1),1)];
            [SAR_relative_rank_acc, SAR_weight, test_mse, train_mse,dep_train_st, dep_test_st] = SAR_assessment(all_Acc_M(tmp_algo_num,:), dep_off_met, ...
                    full_train_dep, full_train_dep, full_test_dep);
            dep_st_fa = zeros(size(all_raw_Met,1),1);
            dep_st_fa(full_train_dep) = dep_train_st;
            dep_st_fa(full_test_dep) = dep_test_st;
            raw_Met = [all_raw_Met(:,1:5), dep_st_fa];
            %}
            raw_Met = all_raw_Met;
            %SSQ 
            full_train_Met = raw_Met(full_train_dep,:);
            train_acc = all_Acc_M(tmp_algo_num, full_train_dep);
            [later_th] = data_driven_threshold_selection_each_factor(full_train_Met, train_acc);
            %min_max_th = [min(full_train_Met); max(full_train_Met)];
                pre_re(train_case_num) = 0;
            
            BTL_rank_acc =[];
            BTL_w = [];
            [~, fin_Met] = threshold_normalization(raw_Met, later_th);
            off_Met = [fin_Met, ones(size(fin_Met,1),1)];
            [SAR_relative_rank_acc, SAR_weight, test_mse, train_mse,SSQ_train, SSQ_test] = SAR_assessment(all_Acc_M(tmp_algo_num,:), off_Met, ...
                    full_train_dep, full_test_dep);
            all_SSQ_train(tmp_algo_num,:) = SSQ_train;
            all_SSQ_test(tmp_algo_num,:) = SSQ_test;
            
            %SNR SSIM
            [SNR_relative_rank_accuracy, SNR_re_acc, SSIM_relative_rank_accuracy, SSIM_re_acc] = SNR_SSIM_assessment(all_Acc_M(tmp_algo_num,:),...
                raw_SNR, raw_SSIM, full_train_dep, full_test_dep);
            
            re = [];
            re.all_Acc = all_Acc_M(tmp_algo_num,:);
            re.train_dep = full_train_dep;
            re.test_dep = full_test_dep;
            re.SSQ_train = SSQ_train;
            re.SSQ_test = SSQ_test;
            
            re.each_fator_com_result = SAR_relative_rank_acc;
            re.each_fator_com_w = SAR_weight;
            re.test_mse = test_mse;
            re.train_mse = train_mse;
            
            re.BTL_acc = BTL_rank_acc;
            re.BTL_w = BTL_w;
            
            re.SNR_acc = SNR_relative_rank_accuracy;
            re.SNR_re_acc = SNR_re_acc;
            re.SSIM_acc = SSIM_relative_rank_accuracy;
            re.SSIM_re_acc = SSIM_re_acc;
            
            %eval(['case_', num2str(train_case_num),  '= re;']);
            %eval(['save(mat_file_name,''case_', num2str(train_case_num), ''',''-append'');'])
            tmp_result(train_case_num, tmp_algo_num) = {re};
    end
        end
        pre_re;
        re =[];
        for kk=1:train_case_number
            eval(['case_', num2str(kk),  '= tmp_result(kk,:);']);
            tmp_re = mean(tmp_result{kk}.each_fator_com_result);
            re = [re, tmp_re];
            eval(['save(mat_file_name,''case_', num2str(kk), ''',''-append'');'])
        end

    end

end
end

close(h)