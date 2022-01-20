function [SNR_relative_rank_accuracy,SNR_re_rank_acc, SSIM_relative_rank_accuracy, SSIM_re_rank_acc,...
    SNR_test_mse, SNR_train_mse, SSIM_test_mse, SSIM_train_mse,SNR_re_rank_acc_10, SSIM_re_rank_acc_10,...
    SNR_testing_dep_SSQ,SNR_training_dep_SSQ,SSIM_testing_dep_SSQ,SSIM_training_dep_SSQ...
    ] = SNR_SSIM_assessment(all_Acc_M, raw_SNR, raw_SSIM, training_dep, testing_dep)
    
    training_dep_SNR = raw_SNR(training_dep,:);
    training_dep_SSIM = raw_SSIM(training_dep, :);
    
    testing_dep_SNR = raw_SNR(testing_dep, :);
    testing_dep_SSIM = raw_SSIM(testing_dep, :);

    SNR_relative_rank_accuracy = relative_rank_accuracy_eva(mean(training_dep_SNR,2)', mean(all_Acc_M(:, training_dep),1), mean(testing_dep_SNR,2)', mean(all_Acc_M(:, testing_dep),1));

    SSIM_relative_rank_accuracy = relative_rank_accuracy_eva(mean(training_dep_SSIM,2)', mean(all_Acc_M(:, training_dep),1), mean(testing_dep_SSIM,2)', mean(all_Acc_M(:, testing_dep),1));
    
    % linear regression model
    nor_Met = raw_SNR;
    train_all_Acc_M = all_Acc_M(:,training_dep);
    options = optimoptions('fmincon','Display','off');
    w0=ones(size(nor_Met,2),1)./size(nor_Met,2);
    SNR_weight = fmincon(@(x)factor_regression(x, nor_Met(training_dep,:), train_all_Acc_M) ,w0,[],[],[], [],[],[],[],options);
    
        %test
    SNR_testing_dep_SSQ = nor_Met(testing_dep,:)*SNR_weight; % each row is one algorithm's ssq
    SNR_testing_dep_SSQ = SNR_testing_dep_SSQ';
    
    SNR_training_dep_SSQ = nor_Met(training_dep,:)*SNR_weight;
    SNR_training_dep_SSQ = SNR_training_dep_SSQ';

    [SNR_re_rank_acc,SNR_re_rank_acc_10] =  relative_rank_accuracy_eva(SNR_training_dep_SSQ,...
        mean(all_Acc_M(:, training_dep),1) , SNR_testing_dep_SSQ, mean(all_Acc_M(:, testing_dep),1));
        
    
    %linear regression
    nor_Met = raw_SSIM;
    train_all_Acc_M = all_Acc_M(:,training_dep);
    w0=ones(size(nor_Met,2),1)./size(nor_Met,2);
    SSIM_weight = fmincon(@(x)factor_regression(x, nor_Met(training_dep,:), train_all_Acc_M) ,w0,[],[],[], [],[],[],[],options);
    
        %test
    SSIM_testing_dep_SSQ = nor_Met(testing_dep,:)*SSIM_weight; % each row is one algorithm's ssq
    SSIM_testing_dep_SSQ = SSIM_testing_dep_SSQ';
    
    SSIM_training_dep_SSQ = nor_Met(training_dep,:)*SSIM_weight;
    SSIM_training_dep_SSQ = SSIM_training_dep_SSQ';

    [SSIM_re_rank_acc,SSIM_re_rank_acc_10] =  relative_rank_accuracy_eva(SSIM_training_dep_SSQ,...
        mean(all_Acc_M(:, training_dep),1) , SSIM_testing_dep_SSQ, mean(all_Acc_M(:, testing_dep),1));
    
    test_acc = mean(all_Acc_M(:, testing_dep),1);
    train_acc = mean(all_Acc_M(:, training_dep),1);
    SNR_test_mse = limited_mse(SNR_testing_dep_SSQ,test_acc);
    SNR_train_mse = limited_mse(SNR_training_dep_SSQ, train_acc);
    SSIM_test_mse = limited_mse(SSIM_testing_dep_SSQ, test_acc);
    SSIM_train_mse = limited_mse(SSIM_training_dep_SSQ, train_acc);
    
end