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
mean_class = mean(classification_accuracy);

load('cross_class_acc.mat');
cross_class_acc = mean_cross_classification_accuracy;

exc_name =["tennis", "footstep"];
app_name =["cl", "sd", "cc"];
h=waitbar(0,'please wait');

load('test_training_set.mat');

%factor_set
factor_combine_set={1,2,3,4,5,[1:5]};
%random factor
%load('rand_f.mat')

train_dep_number =[24];

all_train_set ={};
for kk=1:length(train_dep_number)
    eval(['tmp_train_st = train_set_', num2str(train_dep_number(kk)), ';']);
    all_train_set(kk) = {tmp_train_st};
end
normalization_flag = 5% 1 minmax 2 local 3 global
%nor_mat_name=["_minmax", "_nor", "_globalnor"];
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes"];

for excitation_num=2 % 1 tennis 2 footstep
for app_num=1:2        % 1 cl classification 2 sd signal detection

  
    test_number= 4;

    switch app_num
        case 1
            all_Acc_M = mean(classification_accuracy,1);
        case 2
            all_Acc_M = detection_F1_score;
    end
    
    full_test_st = test_set_4;
    for train_num= 1:length(train_dep_number)

        full_train_st = all_train_set{train_num};
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/fa_',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];
        
        %save(mat_file_name, 'full_train_st', 'full_test_st');
        
        waitbar(train_num / length(train_dep_number), h, ['exc ', num2str(excitation_num),...
           ' app ', num2str(app_num), ' case ', num2str(train_num)]);
                
        train_number = train_dep_number(train_num);
        train_case_number = round(2000/(48-train_number))+1;
        tmp_result = cell(1, train_case_number);
    if excitation_num == 1 % tennis
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse, new_noise_ECB, full_SNR] = tennis_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = rand_single_exc_tennis_factor_generate('../', support_sc);
    else
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse,new_noise_ECB] = footstep_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = rand_single_exc_footstep_factor_generate('../',support_sc);
    end
  
    %new_factor_M = [ABRH_Met, new_ECB_fa, bck_pse', sig_pse', sig_pse'-bck_pse'];
    sele_ABRH= ABRH_Met(:,[1,2,4]);
    new_factor_M = [sele_ABRH, new_ECB_fa(:,2:3)];
    
    raw_Met = new_factor_M;
        parfor train_case_num=1:train_case_number
            
            full_train_dep = full_train_st(train_case_num,:);
            %full_test_dep = full_test_st(train_case_num,:);
            full_test_dep =1:48;
            full_test_dep(full_train_dep) = [];

            raw_train_Met = raw_Met(full_train_dep,:);
         
            each_fator_com_result =[];
            each_factor_test_mse ={};
            each_factor_train_mse ={};
            each_factor_test_ssq={};
            each_factor_train_ssq={};
            each_factor_test_acc={};
            each_factor_train_acc={};
            for factor_com=1:length(factor_combine_set)
                tmp_factor_set =factor_combine_set{factor_com};
                selected_factor = raw_Met(:, tmp_factor_set);
                
                selected_train_factor = selected_factor(full_train_dep,:);
                train_acc = all_Acc_M(full_train_dep);
                %if factor_com == length(factor_combine_set)
                [vote_pra, full_SAR_pra, full_test_mse, full_train_mse,...
                    full_test_SSQ, full_train_SSQ,full_test_Acc,full_train_Acc...
                    ] = vote_SAR_assessment(all_Acc_M, selected_factor, full_train_dep, full_test_dep,normalization_flag);
                %{
                else
                [SNR_relative_rank_accuracy, SNR_re_acc, SSIM_relative_rank_accuracy, SSIM_re_acc,...
                SNR_test_mse, SNR_train_mse, SSIM_test_mse, SSIM_train_mse,SNR_re_rank_acc_10,SSIM_re_rank_acc_10,...
                SNR_testing_dep_SSQ,SNR_training_dep_SSQ,SSIM_testing_dep_SSQ,SSIM_training_dep_SSQ...
                ] = SNR_SSIM_assessment(mean(all_Acc_M,1),...
                selected_factor, selected_factor, full_train_dep, full_test_dep);
                vote_pra = SNR_relative_rank_accuracy;
                full_test_mse = NaN;
                full_train_mse = NaN;
                full_test_SSQ = SNR_testing_dep_SSQ;
                full_train_SSQ = SNR_training_dep_SSQ;
                full_test_Acc = all_Acc_M(full_test_dep);
                full_train_Acc = all_Acc_M(full_train_dep);
                end
                %}
                each_fator_com_result(factor_com,:) = vote_pra;
                each_factor_test_mse(factor_com) = {full_test_mse};
                each_factor_train_mse(factor_com) = {full_train_mse};
                
                %
                each_factor_test_ssq(factor_com)={full_test_SSQ};
                each_factor_train_ssq(factor_com)={full_train_SSQ};
                each_factor_test_acc(factor_com)={full_test_Acc};
                each_factor_train_acc(factor_com)={full_train_Acc};
            end

            re=[];
            re.each_fator_com_result = each_fator_com_result;
            re.test_mse = each_factor_test_mse;
            re.train_mse = each_factor_train_mse;
            re.BTL_acc = 0;
            re.test_ssq = each_factor_test_ssq;
            re.train_ssq = each_factor_train_ssq;
            re.test_acc = each_factor_test_acc;
            re.train_acc = each_factor_train_acc;
            
            tmp_result(train_case_num) = {re};
        end
        
        for kk=1:train_case_number
            eval(['case_', num2str(kk),  '= tmp_result{kk};']);
            eval(['save(mat_file_name,''case_', num2str(kk), ''',''-append'');'])
        end
    end

end
end

close(h)