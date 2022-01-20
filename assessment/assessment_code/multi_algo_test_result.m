clear all
%close all
clc;

exc_name =["tennis", "footstep"];
full_exc_name=["Standard Excitation", "Human Excitation"];
app_name =["cl", "sd", "sd_tp"];
full_app_name = ["Event Classification", "Event Detection"];
train_dep_number =[24];

cmap =[[0.4660 0.6740 0.1880];[0 0.4470 0.7410];[0.8500 0.3250 0.0980]];
SAR_24_result =[];
for excitation_num=1:2 % 1 tennis 2 footstep
   
for app_num=[1]        % 1 cl classification 2 sd signal detection

    all_case_SAR =[];
    all_case_BTL =[];
    all_case_SNR = [];
    all_case_SSIM = [];
    all_case_SNR_re = [];
    all_case_SSIM_re = [];
    fin_weight_std =[];
    
    algo_number =9
    if app_num ==2
        algo_number =1;
    end
    
    
    for train_num= 1:length(train_dep_number)
        train_number = train_dep_number(train_num);

        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), '_nor_no3.mat'];% nor_multi
        load(mat_file_name);
        %conclustion
        %detection
        %tennis ball nor:lsee: 77.3 multi: 77.6 less less: 77.7 no three
        %77.2
        %            mmax:less 79.6 multi:78.5
        %footstep  nor_less: 83.9 multi: 83.7  less less: 80.9 no three
        %80.4
        %            mmax:less 77.6 multi:78.2
        
        %classification 
        %tennis nor: less:77.3 multi:78.7  less lsee:76.6 no three 77.8
          %     mmax: less:76.5 multi:77.2
          %footstep nor: less:73 multi:81.5  less less:72.2 no three 81.1
          %     mmax: less:68.1 multi:75.7
        tmp_case_SAR = [];
        tmp_case_SNR = [];
        tmp_case_SSIM = [];
        tmp_weight =[];
        
        pre_re =[];
        vote_re=[];
        all_algo_re =[];
        for train_case_num=1:200
            eval(['case_re = case_', num2str(train_case_num), ';'])
            
            full_test_Acc =[];
            full_train_Acc =[];
            full_test_SSQ =[];
            full_train_SSQ =[];
          
            
                mean_re = mean( case_re{end}.each_fator_com_result);
                pre_re(train_case_num) = mean_re;
       
            
            single_algo_re=[];
            for algo_n=1:algo_number
                tmp_re = case_re{algo_n};
                
            single_algo_re(algo_n) = mean(tmp_re.each_fator_com_result);
            if algo_n==10
                continue;
            end
            all_Acc = tmp_re.all_Acc;
            train_dep = tmp_re.train_dep;
            test_dep = tmp_re.test_dep;
            SSQ_train = tmp_re.SSQ_train;
            SSQ_test = tmp_re.SSQ_test;
            full_test_Acc(algo_n,:) = all_Acc(test_dep);
            full_train_Acc(algo_n,:) = all_Acc(train_dep);
            full_test_SSQ(algo_n,:) = SSQ_test;
            full_train_SSQ(algo_n,:) = SSQ_train;
                
            SAR_re = tmp_re.each_fator_com_result;
            SNR_re = tmp_re.SNR_acc;
            SSIM_re = tmp_re.SSIM_acc;
            BTL_re = tmp_re.BTL_acc;
            
            tmp_case_SAR(train_case_num,algo_n) = mean(SAR_re);
            end
            all_algo_re(train_case_num, :) = single_algo_re;
            % vote
            tmp_vote_re =[];
            for test_case=1:size(full_test_Acc,2)
                tmp_test_acc = full_test_Acc(:, test_case);
                tmp_test_SSQ = full_test_SSQ(:, test_case);
                
                acc_re = full_train_Acc > tmp_test_acc;
                ssq_re = full_train_SSQ > tmp_test_SSQ;
                
                fin_acc_re = sum(acc_re);
                fin_ssq_re = sum(ssq_re);
                bool_acc_re = fin_acc_re >= size(full_test_Acc,1)/2;
                bool_ssq_re = fin_ssq_re >= size(full_test_Acc,1)/2;
                
               tmp_vote_re(test_case) = sum(bool_acc_re ==bool_ssq_re)/size(full_train_Acc,2);
            end
            vote_re(train_case_num) = mean(tmp_vote_re);
        end
        
        rre=[mean(vote_re),mean(pre_re), mean(all_algo_re)]
        SAR_24_result =[SAR_24_result; rre(1:end-1)];
        
    end

end

end

%%
figure
bar(SAR_24_result');
la =["Vote", "Mean value", "Linear\newlineSVM", "RBF\newlineSVM", "Random\newlineForest",  "k-NN",...
        "Naive\newlineBayes", "XGBoost","    Logistic\newlineRegression", "Extra\newlineTrees"];
xticklabels(la)
ylabel('Pairwise Rank Accuracy')
for xx=1:size(SAR_24_result,1)
    for yy=1:size(SAR_24_result,2)
        tmp_x = yy+ (xx-1.5)*2*0.2;
        text(tmp_x, SAR_24_result(xx,yy), num2str(100*SAR_24_result(xx,yy),'%.1f'),'vert','bottom','horiz','center');
    end
end

legend('Tennis ball', 'Footstep')
ylim([0 1])
      

