clear all
close all
clc;

exc_name =["tennis", "footstep"];
full_exc_name=["Standard Excitation", "Human Excitation"];
app_name =["cl", "sd", "cc"];
full_app_name = ["Event Classification", "Event Detection","Cross Classification"];

train_dep_number = [8,12,16,20,24];

xlabel_name=string(train_dep_number);

pra_result =[];
rmse_result =[];
error_result=[];
cmap2 =[[0.7 0.7 0.7];[0.4660 0.6740 0.1880]];
color_exc =[[0.4660 0.6740 0.1880];[0.4660 0.6740 0.1880]];
normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes","_partGD","_BTL"];
sele_app_set =[1,2];
for excitation_num = 1:2 % 1 tennis 2 footstep

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
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/train_size_no35',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];
        %nor:our method pra object;  minmax; msenor: our method change to
        %mse object; bayesnor: global normal
        load(mat_file_name);
        
        tmp_case_SAR = [];
        tmp_case_SNR = [];
        tmp_case_SSIM = [];
        tmp_case_SNR_re =[];
        tmp_case_SSIM_re =[];
        tmp_weight =[];
        tmp_test_case_PRA=[];
        tmp_case_error=[];
        tmp_snr_error=[];
        tmp_ssim_error =[];
        total_test_number = 2000;
        
        tmp_case_test_MSE = [];
        tmp_case_SNR_test_MSE = [];
        tmp_case_SSIM_test_MSE =[];
            
        for train_case_num=1:round(total_test_number /(48-train_number))+1
            eval(['tmp_re = case_', num2str(train_case_num), ';'])
            SAR_re = tmp_re.each_fator_com_result;
            SNR_re = tmp_re.SNR_acc;
            SSIM_re = tmp_re.SSIM_acc;
            BTL_re = NaN;
            MSE = tmp_re.test_mse;
            if size(MSE,1)> 8
                MSE(9:end,:)=[];
                MSE = mean(MSE,1);
            end
            tmp_weight(:, train_case_num) = tmp_re.each_fator_com_w;
            
            %PRA
            tmp_case_SAR = [tmp_case_SAR, SAR_re];
            tmp_case_SNR = [tmp_case_SNR, SNR_re];
            tmp_case_SSIM = [tmp_case_SSIM, SSIM_re];
            tmp_case_BTL = NaN;
            tmp_case_SNR_re = [tmp_case_SNR_re, tmp_re.SNR_re_acc];
            tmp_case_SSIM_re = [tmp_case_SSIM_re,tmp_re.SSIM_re_acc];
            
            %test train pra
            test_PRA= NaN(1,48);
            test_PRA(tmp_re.test_dep) = tmp_re.each_fator_com_result;
            tmp_test_case_PRA(train_case_num,:) = test_PRA;
            
            %MSE
            tmp_case_test_MSE = [tmp_case_test_MSE,MSE];
            tmp_case_SNR_test_MSE = [tmp_case_SNR_test_MSE, tmp_re.SNR_test_mse];
            tmp_case_SSIM_test_MSE = [tmp_case_SSIM_test_MSE, tmp_re.SSIM_test_mse];

            %error            
            test_ssq = tmp_re.test_ssq;
            test_acc = tmp_re.test_acc;
            lim_ssq = test_ssq;
            tmp_loc = find(lim_ssq>1);
            %lim_ssq(tmp_loc)=1;
            tmp_loc = find(lim_ssq<0);
            %lim_ssq(tmp_loc)=0;
            current_lim_error = lim_ssq - test_acc;
            tmp_case_error = [tmp_case_error, current_lim_error];
            
            %SNR error
            test_ssq = tmp_re.snr_test_ssq;
                
            lim_ssq = test_ssq;
            tmp_loc = find(lim_ssq>1);
            %lim_ssq(tmp_loc)=1;
            tmp_loc = find(lim_ssq<0);
            %lim_ssq(tmp_loc)=0;
            tmp_snr_error =[tmp_snr_error, lim_ssq - test_acc];  
            
            %SSIM error
            test_ssq = tmp_re.ssim_test_ssq;
                
            lim_ssq = test_ssq;
            tmp_loc = find(lim_ssq>1);
            %lim_ssq(tmp_loc)=1;
            tmp_loc = find(lim_ssq<0);
            %lim_ssq(tmp_loc)=0;
            tmp_ssim_error =[tmp_ssim_error,lim_ssq - test_acc];  
        end
        
        all_case_SAR(:, train_num) = tmp_case_SAR(1:total_test_number)';
        all_case_SNR(:, train_num) = tmp_case_SNR(1:total_test_number)';
        all_case_SSIM(:, train_num) = tmp_case_SSIM(1:total_test_number)';
        all_case_BTL(:, train_num) = tmp_case_BTL;
        all_case_SNR_re(:, train_num) = tmp_case_SNR_re(1:total_test_number)';
        all_case_SSIM_re(:, train_num) = tmp_case_SSIM_re(1:total_test_number)';
        test_case_PRA(train_num,:) = nanmean(tmp_test_case_PRA);
        
        all_case_test_MSE(:, train_num) = tmp_case_test_MSE(1:total_test_number)';
        all_case_SNR_test_MSE(:, train_num) = tmp_case_SNR_test_MSE(1:total_test_number)';
        all_case_SSIM_test_MSE(:, train_num) = tmp_case_SSIM_test_MSE(1:total_test_number)';
        
        %error
        all_case_error(:,train_num)=tmp_case_error(1:total_test_number)';
        all_case_snr_error(:,train_num) =tmp_snr_error(1:total_test_number)';
        all_case_ssim_error(:,train_num) =tmp_ssim_error(1:total_test_number)'; 
        all_case_weight(train_num)={tmp_weight};
    end
    %{
    %PRA
    figure
    mean_re = [mean(all_case_SAR)', mean(all_case_SNR)', mean(all_case_SSIM)'];
    std_re = [std(all_case_SAR)', std(all_case_SNR)', std(all_case_SSIM)'];
    
    x_len =  length(train_dep_number);
    bar(train_dep_number,mean_re);
    hold on
    errorbar(train_dep_number-0.5, mean_re(:,1), std_re(:,1),'ok');
    errorbar(train_dep_number-0, mean_re(:,2), std_re(:,2),'ok');
    errorbar(train_dep_number+0.5, mean_re(:,3), std_re(:,3),'ok');
    xticks(train_dep_number)
    xticklabels(xlabel_name);
    %legend('our method', 're SNR', 're SSIM', 'SNR', 'SSIM');
    legend('our method', 'SNR', 'SSIM');
    title([char(full_exc_name(excitation_num)),'   ', char(full_app_name(app_num))])
    xlabel('training set size')
    ylabel('PRA')
    ylim([0.5 1])
    bar_ind_loc=[-0.2,0,0.2];
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = train_dep_number(xx)+ bar_ind_loc(yy);
        text(tmp_x, mean_re(xx,yy), num2str(100*mean_re(xx,yy),'%.1f'),'vert','bottom','horiz','center');
    end
    end
    %}
    %RMSE
    mean_RMSE = [sqrt(mean(all_case_test_MSE))', sqrt(mean(all_case_SNR_test_MSE))', sqrt(mean(all_case_SSIM_test_MSE))'];
    std_RMSE = [std(sqrt(all_case_test_MSE))', std(sqrt(all_case_SNR_test_MSE))', std(sqrt(all_case_SSIM_test_MSE))'];
    fi=figure
    set(gcf,'position',[300 100 700 330] );
    bar(train_dep_number,mean_RMSE);
    hold on
    errorbar(train_dep_number-1, mean_RMSE(:,1), std_RMSE(:,1),'ok');
    errorbar(train_dep_number-0, mean_RMSE(:,2), std_RMSE(:,2),'ok');
    errorbar(train_dep_number+1, mean_RMSE(:,3), std_RMSE(:,3),'ok');
    %}
    xticks(train_dep_number)
    xticklabels(xlabel_name);
    title([char(full_exc_name(excitation_num)),'   ', char(full_app_name(app_num))])
    legend('Our method', 'SNR', 'SSIM','location', 'best','Orientation','horizontal');
    ylim([0 0.5])
    ylabel('RMSE')
    err_loc =[-1,0,1];
    for xx=1:size(mean_RMSE,1)
    for yy=1:size(mean_RMSE,2)
        tmp_x = train_dep_number(xx)+err_loc(yy);
        bb =['(', num2str(std_RMSE(xx,yy),'%.2f'), ')'];
        text(tmp_x, mean_RMSE(xx,yy)+0.01, {num2str(mean_RMSE(xx,yy),'%.2f'), bb},'vert','bottom','horiz','center');
    end
    end
    figue_name =['./figures/',char(exc_name(excitation_num)),'_',char(full_app_name(app_num)), '_train_size_rmse.jpg'];
    %saveas(fi, figue_name);
    
    selected_train_size_idx = 5;
    pra_result =[pra_result, {[all_case_SNR(:,selected_train_size_idx), all_case_SSIM(:,selected_train_size_idx),all_case_SAR(:, selected_train_size_idx)]}];
    rmse_result = [rmse_result, {[all_case_SNR_test_MSE(:,selected_train_size_idx), all_case_SSIM_test_MSE(:,selected_train_size_idx),all_case_test_MSE(:, selected_train_size_idx)]}] 
    error_result = [error_result,{[all_case_snr_error(:,selected_train_size_idx), all_case_ssim_error(:,selected_train_size_idx), all_case_error(:,selected_train_size_idx)]}];
    only_pra{app_num} = all_case_SAR;
    only_rmse{app_num} = all_case_test_MSE;
    only_error{app_num} = all_case_error;
    only_weight{app_num} = all_case_weight;%selected_train_size_idx};
end
%{
    fi = figure
    class= only_pra{1};
    if app_num ==2
        sig_det = only_pra{2};
    else
        sig_det = only_pra{3};
    end
    set(gcf,'position',[300 100 600 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)

    mean_re = [mean(class)', mean(sig_det)']
    std_re =[std(class)', std(sig_det)'];
    plot(train_dep_number-0.2, mean_re(:,1),'-o', 'linewidth',2, 'color',cmap2(1,:) );
    hold on
    plot(train_dep_number+0.2, mean_re(:,2), '-s','linewidth', 2, 'color',cmap2(2,:) );
    hold on

    hold on
    errorbar(train_dep_number-0.2, mean_re(:,1), std_re(:,1), 'k','LineWidth', 1);
    hold on
    errorbar(train_dep_number+0.2, mean_re(:,2), std_re(:,2), 'k','LineWidth', 1);
    xticks(train_dep_number)
    xticklabels(xlabel_name);
    legend('Event Classification', 'Event Detection','location', 'best','Orientation','horizontal');
    
    if app_num==1
        xlabel('The Number of Training Deployments');
    else
        xlabel('The Number of Training Deployments');
    end
    ylabel('PRA    ')
    ylim([0.5 1])
    yticks([0, 0.25, 0.5, 0.75, 1])
    xlim([train_dep_number(1)-0.5 train_dep_number(end)+0.5])
    
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size.jpg'];
    saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size.fig'];
    saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size.eps'];
    saveas(fi, figue_name, 'epsc');
    %}

    %RMSE
    %{
    fi = figure
    class= only_rmse{1};
    if app_num ==2
        sig_det = only_rmse{2};
    else
        sig_det = only_rmse{3};
    end

    set(gcf,'position',[300 100 600 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)

    %{
    mean_re = [mean(class)', mean(sig_det)']
    std_re =[std(class)', std(sig_det)'];
    plot(train_dep_number-0.2, mean_re(:,1),'-o', 'linewidth',2, 'color',cmap2(1,:) );
    hold on
    plot(train_dep_number+0.2, mean_re(:,2), '-s','linewidth', 2, 'color',cmap2(2,:) );
    hold on
    errorbar(train_dep_number-0.2, mean_re(:,1), std_re(:,1), 'k','LineWidth', 1);
    hold on
    errorbar(train_dep_number+0.2, mean_re(:,2), std_re(:,2), 'k','LineWidth', 1);
    %}
    fin_re = cat(1, reshape(class, [1 size(class)]),reshape(sig_det, [1 size(sig_det)]));
    aboxplot(fin_re, 'labels', train_dep_number,'colormap', cmap2);
    xticks(1:length(train_dep_number))
    xticklabels(xlabel_name);
    legend('Event Classification', 'Event Detection','location', 'best','Orientation','horizontal');
    %xlim([train_dep_number(1)-0.5 train_dep_number(end)+0.5])
    xlabel('The Number of Training Deployments');
    ylabel('RMSE    ')
    %ylim([0 0.25])
    
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_rmse.jpg'];
    saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_rmse.fig'];
    saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_rmse.eps'];
    saveas(fi, figue_name, 'epsc');
    %}
    
    %% error
    fi = figure
    class= only_error{1};
    if app_num ==2
        sig_det = only_error{2};
    else
        sig_det = only_error{3};
    end
    

    
    set(gcf,'position',[300 100 800 330] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)

    %fin_re = cat(1, reshape(class, [1 size(class)]),reshape(sig_det, [1 size(sig_det)]));
    %aboxplot(fin_re, 'labels', train_dep_number,'colormap', cmap2);
    mean_re = [nanmean(abs(class))', nanmean(abs(sig_det))'];
    std_re =[nanstd(abs(class))', nanstd(abs(sig_det))'];
    bar(train_dep_number, mean_re);
    hold on;
    errorbar(train_dep_number-0.5, mean_re(:,1), std_re(:,1), 'ok');
    hold on
    errorbar(train_dep_number+0.5, mean_re(:,2), std_re(:,2), 'ok');
    
    xticklabels(xlabel_name);
    legend('Event Classification', 'Event Detection','location', 'best','Orientation','horizontal');
    
    xlabel('The Number of Training Deployments');
    ylabel('Absolute Error')
    %ylim([0 0.25])
    
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_error_box.jpg'];
    %saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_error_box.fig'];
    %saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_error_box.eps'];
    %saveas(fi, figue_name, 'epsc');
    
    %% wegith plot
    only_weight;
    all_cl_wei= only_weight{1};
    all_de_wei = only_weight{2};
    
    class = all_cl_wei{5}';
    sig_det = all_de_wei{5}';
    %class(:,8:end)=[];
    %sig_det(:,8:end)= [];
    %normalize weight
    %class = abs(class) ./ sum(abs(class),2);
    %sig_det = abs(sig_det) ./ sum(abs(sig_det),2);
    fi= figure
    set(gcf,'position',[300 100 800 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    fin_re =cat(1,reshape(class, [1 size(class)]), reshape(sig_det, [1 size(sig_det)]));
    color_set=[[0 0.4470 0.7410]; [0.3010 0.7450 0.9330]];
    aboxplot(fin_re, 'labels',[   "w_1", "w_2", "w_3", "w_4", "w_5",'c'],'colormap', color_set, 'orientation', 'horizontal');
        
    mean_re = [nanmean(class)', nanmean(sig_det)'];
    std_re =[std(class)', std(sig_det)'];
    cl_fu =[];
    de_fu =[];
    for kk=1:size(class,2)
        tmp_cl = class(:,kk);
        tmp_de = sig_det(:,kk);
        
        [q1 q2 q3 fuc fl ou ol] = quartile(tmp_cl);
        [q1 q2 q3 fud fl ou ol] = quartile(tmp_de);
        cl_fu(kk) = fuc;
        de_fu(kk) = fud;
    end
    fu_set =[cl_fu', de_fu'];
    
    
    tmp_loc=[-0.2, 0.2]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, fu_set(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    
    le = legend('Event Classification', 'Event Detection','location', 'north','Fontsize',12);
    tbb = le.Position;
    tbb(1) = tbb(1)+0.2;
    set(le, 'Position', tbb)
    %legend boxoff
    ylim([0 0.6])
    ylabel('Weight Value')
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    xlabel('Assessment Factor')
    %title('Selected Parameters of Two Sensing Tasks')
    
    figue_name =['./figures/',char(exc_name(excitation_num)),'_weight_differ.jpg'];
    saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_weight_differ.fig'];
    saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_weight_differ.eps'];
    saveas(fi, figue_name, 'epsc');
    
    figure
    plot(class')
    xticks(1:6)
    xticklabels({'w1', 'w2', 'w3', 'w4', 'w5', 'c'})
    title('Classification')
    figure
    plot(sig_det')
    xticks(1:6)
    xticklabels({'w1', 'w2', 'w3', 'w4', 'w5', 'c'})
    title('Detection')
end
     

%% RMSE
fi =figure
set(gcf,'position',[300 100 800 400] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)

%set(gcf,'position',[300 300 600 480] );
for app_num=1:2
    subplot(2,1, app_num);

    tennis = rmse_result{app_num};
    foot = rmse_result{length(sele_app_set)+app_num};

    mean_re = [sqrt(mean(tennis))', sqrt(mean(foot))'];
    std_re =[std(sqrt(tennis))', std(sqrt(foot))'];
    
    bar_handle=bar(mean_re);
    set(bar_handle(1),'FaceColor',cmap2(1,:))
    set(bar_handle(2),'FaceColor',cmap2(2,:))
    hold on
    errorbar([1:3]-0.15, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar([1:3]+0.15, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    xticks([1:3])
    xticklabels(["SNR", "SSIM","TSQ"]);
    legend('Manual Assessment (Baseline 1)',  'Auto Assessment (AutoQual)', 'location', 'south', 'Orientation','horizontal');
    switch app_num
        case 1
            title(['(a) ',char(full_app_name(app_num))]);
        case 2
            title(['(b) ',char(full_app_name(app_num))]);
        case 3
            title(['(c) ',char(full_app_name(app_num))]);
    end
    ylabel('RMSE')
    %yticks([0, 0.25, 0.5, 0.75, 1])
    ylim([0 0.6])
    
    tmp_loc=[-0.15, 0.15]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy)+std_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
        set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))
end
figue_name =['./figures/merged_training_size_rmse.jpg'];
%saveas(fi, figue_name);
figue_name =['./figures/merged_training_size_rmse.fig'];
%saveas(fi, figue_name);
figue_name =['./figures/merged_training_size_rmse.eps'];
%saveas(fi, figue_name, 'epsc');


%% Error
fi =figure
set(gcf,'position',[300 100 800 400] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)

%set(gcf,'position',[300 300 600 480] );
for app_num=1:2
    subplot(2,1, app_num);

    tennis = error_result{app_num};
    foot = error_result{length(sele_app_set)+app_num};

    %fin_re = cat(1, reshape(tennis, [1 size(tennis)]),reshape(foot, [1 size(foot)]));
    %aboxplot(fin_re, 'labels', train_dep_number,'colormap', cmap2);
    mean_re = [mean(abs(tennis))', mean(abs(foot))'];
    std_re =[std(abs(tennis))', std(abs(foot))'];
    
    bar_handle=bar(mean_re, 'barwidth',0.7);
    set(bar_handle(1),'FaceColor',cmap2(1,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    set(bar_handle(2),'FaceColor',cmap2(2,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
        hold on
    errorbar([1:3]-0.15, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar([1:3]+0.15, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    xticks([1:3])
    xticklabels(["SNR", "SSIM","TSQ"]);

    switch app_num
        case 1
            title(['(a) ',char(full_app_name(app_num))]);
        case 2
            title(['(b) ',char(full_app_name(app_num))]);
        case 3
            title(['(c) ',char(full_app_name(app_num))]);
    end
    ylabel('Absolute Error')
    ylim([0 0.5])
    yticks([0:0.1:0.5])
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))
end
    le=legend('Manual Assessment (Baseline 1)',  'Auto Assessment (AutoQual)', 'location', 'south','Fontsize',12);
    bb= le.Position;
    bb(1)= 0.58;
    bb(2)= 0.79;
    le.Position =bb;
    %legend boxoff
figue_name =['./figures/merged_training_size_error.jpg'];
%saveas(fi, figue_name);
figue_name =['./figures/merged_training_size_error.fig'];
%saveas(fi, figue_name);
figue_name =['./figures/merged_training_size_error.eps'];
%saveas(fi, figue_name, 'epsc');


%% Error SNR SSIM

tennis_class = error_result{1};
tennis_det = error_result{2};
foot_class= error_result{3};
foot_det = error_result{4};

cmap2 =[[0.9 0.9 0.9];[0.6 0.6 0.6];[0.4660 0.6740 0.1880]];

fi =figure
set(gcf,'position',[300 100 800 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    
    mean_re = [mean(abs(foot_class))', mean(abs(foot_det))']';
    std_re =[std(abs(foot_class))', std(abs(foot_det))']';
    
    bar_handle=bar(mean_re, 'barwidth',0.7);
    set(bar_handle(1),'FaceColor',cmap2(1,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    set(bar_handle(2),'FaceColor',cmap2(2,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    set(bar_handle(3),'FaceColor',cmap2(3,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
        hold on
    errorbar([1:2]-0.22, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar([1:2]+0, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    hold on
    errorbar([1:2]+0.22, mean_re(:,3), std_re(:,3), 'ok','LineWidth', 1);
    tmp_loc=[-0.22, 0, 0.22]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    xticks([1:2])
    xticklabels(["Event Classification", "Event Detection"]);

    ylabel('Absolute Error')
    xlabel('Sensing Task')
    %title('SNR,SSIM')
    ylim([0 0.5])
    yticks([0:0.1:0.5])
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))

    le=legend('SNR',  'SSIM', 'AutoQual', 'location', 'south','Fontsize',12,'Orientation','horizontal');
    bb= le.Position;
    bb(1)= 0.33;
    bb(2)= 0.78;
    le.Position =bb;
   % legend boxoff
figue_name =['./figures/SNR_SSIM_Our.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/SNR_SSIM_Our.fig'];
saveas(fi, figue_name);
figue_name =['./figures/SNR_SSIM_Our.eps'];
saveas(fi, figue_name, 'epsc');

%% tennis foostep
fi =figure
set(gcf,'position',[300 100 800 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    
  
    mean_re = [mean(abs(tennis_class(:,3))), mean(abs(foot_class(:,3)));
        mean(abs(tennis_det(:,3))), mean(abs(foot_det(:,3)));];
    std_re =[std(abs(tennis_class(:,3))), std(abs(foot_class(:,3)));
        std(abs(tennis_det(:,3))), std(abs(foot_det(:,3)));]';
    
    bar_handle=bar(mean_re, 'barwidth',0.7);
    set(bar_handle(1),'FaceColor',cmap2(2,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    set(bar_handle(2),'FaceColor',cmap2(3,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    %set(bar_handle(3),'FaceColor',cmap2(3,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
        hold on
    errorbar([1:2]-0.15, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar([1:2]+0.15, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    hold on
    %errorbar([1:2]+0.22, mean_re(:,3), std_re(:,3), 'ok','LineWidth', 1);
    tmp_loc=[-0.15, 0.15]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'), bb},'vert','bottom','horiz','center');
    end
    end
    xticks([1:2])
    xticklabels(["Event Classification", "Event Detection"]);

    ylabel('Absolute Error')
    xlabel('Sensing Task')
    ylim([0 0.25])
    yticks([0:0.1:0.5])
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))

    le=legend('Manual Assessment (Baseline1)',  'Auto Assessment (AutoQual)', 'location', 'south','Fontsize',12,'Orientation','horizontal');
    bb= le.Position;
    %bb(1)= 0.23;
    bb(2)= 0.82;
    le.Position =bb;
   % legend boxoff
figue_name =['./figures/Manual_auto.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/Manual_auto.fig'];
saveas(fi, figue_name);
figue_name =['./figures/Manual_auto.eps'];
saveas(fi, figue_name, 'epsc');