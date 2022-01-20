clear all
close all
clc;

exc_name =["tennis", "footstep"];
full_exc_name=["Standard Excitation", "Human Excitation"];
app_name =["cl", "sd", "cc"];
full_app_name = ["Event Classification", "Event Detection","Cross Classification"];

train_dep_number = [5];

xlabel_name=string(train_dep_number);

pra_result =[];
rmse_result =[];
error_result=[];
cmap2 =[[0.7 0.7 0.7];[0.4660 0.6740 0.1880]];
color_exc =[[0.4660 0.6740 0.1880];[0.4660 0.6740 0.1880]];
normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes","_partGD","_BTL"];
sele_app_set =[1,2];
for excitation_num = 2 % 1 tennis 2 footstep

    only_pra ={};
    only_rmse ={};
    only_error={};
    only_weight ={};
for app_num=sele_app_set        % 1 cl classification 2 sd signal detection

    all_case_SAR =[];
    all_case_BTL =[];
    all_case_SNR = [];
    all_case_SSIM = [];
    all_case_SNR_re = [];
    all_case_SSIM_re = [];
    fin_weight_std =[];
    all_case_test_MSE =[];
    all_case_SNR_test_MSE =[];
    all_case_SSIM_test_MSE =[];
    test_case_PRA =[];
    
    all_case_SAR_10 =[];
    all_case_SNR_10 = [];
    all_case_SSIM_10 = [];
    
    all_case_error=[];
    all_case_error_mean=[];
    all_case_error_std=[];
    all_case_snr_error =[];
    all_case_ssim_error =[];
    all_case_weight={};
    
    for train_num= 1:length(train_dep_number)
        train_number = train_dep_number(train_num);

        % add_necb %sigecb
                mat_file_name = ['./',char(exc_name(excitation_num)),'_result/recall_',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];%nor %msenor
        load(mat_file_name);
        all_recall=[];
        for train_case_num=1:21
            eval(['tmp_re = case_', num2str(train_case_num), ';'])
            test_ssq = tmp_re.test_ssq;
            test_acc = tmp_re.test_acc;
            
            tmp_ssq = reshape(test_ssq, 4,[])';
            tmp_acc = reshape(test_acc, 4,[])';
            recall=[];
            for tmp_env = 1:size(tmp_ssq,1)
                current_ssq = tmp_ssq(tmp_env,:);
                current_acc = tmp_acc(tmp_env,:);
                [r1, r2, r3]= Recall_metrics(current_acc, current_ssq);
                recall=[recall; r1, r2, r3];
            end
            all_recall = [all_recall; recall];
        end
        recall_rate = sum(all_recall,1) ./ size(all_recall,1)
    end
end
end