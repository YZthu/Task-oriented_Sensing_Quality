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
app_name =["cl", "sd","cc"];
h=waitbar(0,'please wait');

load('test_training_set.mat');


normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes"];

%14,16,18,
train_dep_number = [32]% 5 8 36 %[8,10,12,14,16,18, 20, 24]%,28,32,36,40];
%train_dep_number = [36,40];
%train_dep_number1 = [8,9,10,11,13,14,15,18];
%train_dep_number =[train_dep_number1, train_dep_number2];
for excitation_num=1 % 1 tennis 2 footstep
for app_num=2     % 1 cl classification 2 sd detection
  
    test_number= 4;

    switch app_num
        case 1
            all_Acc_M = mean(classification_accuracy,1);
        case 2
            all_Acc_M = detection_F1_score;
        case 3
            all_Acc_M = cross_class_acc;
    end

    % local factor read
    % concentrate band scale selectio
    t1 =clock;
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

    raw_Met = new_factor_M;
    raw_SNR = SNR;
    raw_SSIM = SSIM;
       %}
        train_number = train_dep_number(train_num);
        eval(['full_train_st = train_set_', num2str(train_number), ';']);
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/train_size',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];%nor %msenor

            t2 = clock;
            one_case_time = etime(t2,t1)
            t1 = t2;
waitbar(train_num / length(train_dep_number), h, ['exc ', num2str(excitation_num),...
           ' app ', num2str(app_num), ' case ', num2str(train_num)]);
        load(mat_file_name);
                
        train_case_number = 20;%size(full_train_st,1);
        tmp_result = cell(1, train_case_number);
        pre_re = zeros(1, train_case_number);
        lat_re = zeros(1, train_case_number);
                
        for kk=1:train_case_number
            eval(['tmp_result{', num2str(kk),  '}= case_',num2str(kk),';']);
        end
        
        parfor train_case_num=1:train_case_number 
            %maxNumCompThreads(2);
    if excitation_num == 1 % tennis
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse] = tennis_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = rand_single_exc_tennis_factor_generate('../', support_sc);
    else
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse] = footstep_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = rand_single_exc_footstep_factor_generate('../',support_sc);
    end
  
    new_factor_M = [ABRH_Met, new_ECB_fa, bck_pse', sig_pse', sig_pse'-bck_pse'];
    raw_Met = new_factor_M;
    %local_bandwidth = [sig_bandwidth, sig_sub_bck, bck_bandwidth];
    raw_SNR = nanmean(SNR,2);
    raw_SSIM = nanmean(SSIM,2);
    
            full_train_dep = full_train_st(train_case_num,:);
            %full_test_dep = full_test_st(train_case_num,:);
            full_test_dep = 1:48;
            full_test_dep(full_train_dep) = [];

            %SNR SSIM
            [SNR_relative_rank_accuracy, SNR_re_acc, SSIM_relative_rank_accuracy, SSIM_re_acc,...
                SNR_test_mse, SNR_train_mse, SSIM_test_mse, SSIM_train_mse,SNR_re_rank_acc_10,SSIM_re_rank_acc_10,...
                SNR_testing_dep_SSQ,SNR_training_dep_SSQ,SSIM_testing_dep_SSQ,SSIM_training_dep_SSQ...
                ] = SNR_SSIM_assessment(mean(all_Acc_M,1),...
                raw_SNR, raw_SSIM, full_train_dep, full_test_dep);
            
            re = tmp_result{train_case_num};
            
            re.snr_test_ssq = SNR_testing_dep_SSQ;
            re.snr_train_ssq = SNR_training_dep_SSQ;
            re.ssim_test_ssq = SSIM_testing_dep_SSQ;
            re.ssim_train_ssq = SSIM_training_dep_SSQ;
            %gep pra
            %re.SAR_acc_10 = SAR_relative_rank_acc_10;
            %re.SNR_acc_10 = SNR_re_rank_acc_10;
            %re.SSIM_acc_10 = SSIM_re_rank_acc_10;
            
            
            %eval(['case_', num2str(train_case_num),  '= re;']);
            %eval(['save(mat_file_name,''case_', num2str(train_case_num), ''',''-append'');'])
            tmp_result(train_case_num) = {re};

        end
        re =[];
        for kk=1:train_case_number
            eval(['case_', num2str(kk),  '= tmp_result{kk};']);
            tmp_re = mean(tmp_result{kk}.each_fator_com_result);
            re = [re, tmp_re];
            eval(['save(mat_file_name,''case_', num2str(kk), ''',''-append'');'])
        end

    end

end
end

close(h)