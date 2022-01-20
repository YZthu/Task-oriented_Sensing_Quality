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

%% delete other part

normalization_flag = 1% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes","_partGD","_BTL"];

%
train_dep_number = [8,12,16,20,24];

for excitation_num=1:2 % 1 tennis 2 footstep
for app_num=1:2        % 1 cl classification 2 sd detection
  
    test_number= 4;

    switch app_num
        case 1
            all_Acc_M = mean(classification_accuracy,1);
            full_Acc_M = classification_accuracy;
        case 2
            all_Acc_M = detection_F1_score;
            full_Acc_M = detection_F1_score;
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
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/train_size_no35',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];%nor %msenor

            t2 = clock;
            one_case_time = etime(t2,t1)
            t1 = t2;
        waitbar(train_num / length(train_dep_number), h, ['exc ', num2str(excitation_num),...
           ' app ', num2str(app_num), ' case ', num2str(train_num)]);
        %save(mat_file_name, 'full_train_st');
                
        train_case_number = round(2000/(48-train_number))+1;
        tmp_result = cell(1, train_case_number);
        pre_re = zeros(1, train_case_number);
        lat_re = zeros(1, train_case_number);

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
    %local_bandwidth = [sig_bandwidth, sig_sub_bck, bck_bandwidth];
    raw_SNR = nanmean(SNR,2);
    raw_SSIM = nanmean(SSIM,2);
    
    
    after_test_mse = NaN(1,train_case_number);
    gd_test_mse = NaN(1,train_case_number);
        
        parfor train_case_num=1:train_case_number 
    
            full_train_dep = full_train_st(train_case_num,:);
            %full_test_dep = full_test_st(train_case_num,:);
            full_test_dep = 1:48;
            full_test_dep(full_train_dep) = [];
            

            [vote_pra, full_SAR_pra, full_test_mse, full_train_mse,...
                full_test_SSQ, full_train_SSQ,full_test_Acc,full_train_Acc,full_test_gd_mse,...
                SAR_weight,threshold] = vote_SAR_assessment(all_Acc_M, raw_Met, full_train_dep, full_test_dep,normalization_flag, full_Acc_M);
            %[vote_pra, full_SAR_pra, full_test_mse, full_train_mse] = minmax_vote_SAR_assessment(all_Acc_M, raw_Met, full_train_dep, full_test_dep);
            
            SAR_relative_rank_acc = vote_pra;
            %SAR_weight =NaN;
            test_mse = full_test_mse;
            train_mse = full_train_mse;
            
            after_test_mse(train_case_num) = sqrt(mean(full_test_mse));
            gd_test_mse(train_case_num) = sqrt(mean(full_test_gd_mse));
            
            %SNR SSIM
            [SNR_relative_rank_accuracy, SNR_re_acc, SSIM_relative_rank_accuracy, SSIM_re_acc,...
                SNR_test_mse, SNR_train_mse, SSIM_test_mse, SSIM_train_mse,SNR_re_rank_acc_10,SSIM_re_rank_acc_10,...
                SNR_testing_dep_SSQ,SNR_training_dep_SSQ,SSIM_testing_dep_SSQ,SSIM_training_dep_SSQ...
                ] = SNR_SSIM_assessment(mean(all_Acc_M,1),...
                raw_SNR, raw_SSIM, full_train_dep, full_test_dep);
            
            re = [];
            re.each_fator_com_result = SAR_relative_rank_acc;
            re.each_fator_com_w = SAR_weight;
            re.each_threshold = threshold;
            re.test_mse = test_mse;
            re.train_mse = train_mse;
            
            re.test_dep = full_test_dep;
            re.train_dep = full_train_dep;
            re.full_SAR_pra = full_SAR_pra;

            re.SNR_acc = SNR_relative_rank_accuracy;
            re.SNR_re_acc = SNR_re_acc;
            re.SSIM_acc = SSIM_relative_rank_accuracy;
            re.SSIM_re_acc = SSIM_re_acc;
            re.SNR_test_mse = SNR_test_mse;
            re.SNR_train_mse = SNR_train_mse;
            re.SSIM_test_mse = SSIM_test_mse;
            re.SSIM_train_mse = SSIM_train_mse;
            
            re.test_ssq = full_test_SSQ;
            re.train_ssq = full_train_SSQ;
            re.test_acc = full_test_Acc;
            re.train_acc = full_train_Acc;
            
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
        %delete(gcp('nocreate'))
        figure
        plot(after_test_mse);
        hold on
        plot(gd_test_mse);
        legend('After weight', 'GD weight');
        title(['A ',num2str(mean(after_test_mse)), '  gd: ',num2str(mean(gd_test_mse))]);
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