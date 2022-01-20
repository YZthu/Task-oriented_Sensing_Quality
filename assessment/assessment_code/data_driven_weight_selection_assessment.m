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

normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes","_partGD","_BTL"];
weight_name=["same_weight","same_weight_minmax","SW"];
%
train_dep_number = [24];

for weight_method=3
    excitation_num=2 % 1 tennis 2 footstep
for app_num=1:2     % 1 cl classification 2 sd detection
  
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

    switch weight_method
        case 1
            weight_train_acc = all_Acc_M;
        case 2
            weight_train_acc = all_Acc_M;
        case 3
            weight_train_acc = (mean_class + detection_F1_score)./2;
    end
    % local factor read
    % concentrate band scale selectio
    t1 =clock;
    for train_num= 1:length(train_dep_number)
        
        train_number = train_dep_number(train_num);
        eval(['full_train_st = train_set_', num2str(train_number), ';']);
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/weight_', char(weight_name(weight_method)),'_',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];%nor %msenor

            t2 = clock;
            one_case_time = etime(t2,t1)
            t1 = t2;
        waitbar(train_num / length(train_dep_number), h, ['wei ', num2str(weight_method),...
           ' app ', num2str(app_num), ' case ', num2str(train_num)]);
        save(mat_file_name, 'full_train_st');
                
        train_case_number = round(2000/(48-train_number))+1;
        tmp_result = cell(1, train_case_number);
        pre_re = zeros(1, train_case_number);
        lat_re = zeros(1, train_case_number);

    if excitation_num == 1 % tennis
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse, new_noise_ECB] = tennis_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = rand_single_exc_tennis_factor_generate('../', support_sc);
    else
        [ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa, bck_pse, sig_pse,new_noise_ECB] = footstep_factor_generate('../',support_sc);
        %[ABRH_Met, bandwidth_Met, SNR, SSIM, new_ECB_fa] = rand_single_exc_footstep_factor_generate('../',support_sc);
    end
  
    %new_factor_M = [ABRH_Met, new_ECB_fa, bck_pse', sig_pse', sig_pse'-bck_pse'];
    sele_ABRH= ABRH_Met(:,[1,2,4]);
    new_factor_M = [sele_ABRH, new_ECB_fa(:,3:4)];
    
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
            
            full_train_Met = raw_Met(full_train_dep,:);
            full_test_Met = raw_Met(full_test_dep,:);
            
            train_acc = weight_train_acc(full_train_dep);
            test_acc = weight_train_acc(full_test_dep);
            switch weight_method
                case 1
                    [later_th, fin_weight] = data_driven_weight_st_gd(full_train_Met, train_acc, full_test_Met, test_acc);
                    [fin_Met] = sigmoid_normalization(raw_Met, later_th);
                    final_fa = mean(fin_Met,2);
                    add_offset_factor = [final_fa, ones(size(fin_Met,1),1)];
                    SSQ = add_offset_factor*fin_weight;
                case 2
                    later_th = [min(full_train_Met); max(full_train_Met)];
                    [fin_Met] = sigmoid_normalization(raw_Met, later_th);
                    nor_Met = [mean(fin_Met,2), ones(size(fin_Met,1),1)];
                    w0=ones(size(nor_Met,2),1)./size(nor_Met,2);
                    options = optimoptions('fmincon','Display','off');
                    SAR_weight = fmincon(@(x)factor_regression(x, nor_Met(full_train_dep,:), train_acc) ,w0,[],[],[], [],[],[],[],options);
                    SSQ = nor_Met*SAR_weight;
                    fin_weight = SAR_weight;
                case 3
                    sum_fa = mean(raw_Met,2);
                    later_th = [min(sum_fa); max(sum_fa)];
                    [~, fin_Met] = threshold_normalization(sum_fa, later_th);
                    SSQ = fin_Met;
                    fin_weight = NaN;
            end
            
            %SNR SSIM
            full_test_SSQ = SSQ(full_test_dep)';
            full_train_SSQ = SSQ(full_train_dep)';
            full_test_Acc = all_Acc_M(full_test_dep);
            full_train_Acc = all_Acc_M(full_train_dep);
            
            re = [];
            re.each_fator_com_w = fin_weight;
            re.each_threshold = later_th;

            re.test_dep = full_test_dep;
            re.train_dep = full_train_dep;
            
            re.test_ssq = full_test_SSQ;
            re.train_ssq = full_train_SSQ;
            re.test_acc = full_test_Acc;
            re.train_acc = full_train_Acc;

            tmp_result(train_case_num) = {re};

        end
        re =[];
        for kk=1:train_case_number
            eval(['case_', num2str(kk),  '= tmp_result{kk};']);
            eval(['save(mat_file_name,''case_', num2str(kk), ''',''-append'');'])
        end

    end

end
end

close(h)