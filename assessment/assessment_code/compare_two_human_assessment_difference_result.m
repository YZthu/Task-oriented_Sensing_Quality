clear all
close all
clc;

exc_name =["tennis", "human1", "human2"];
full_exc_name=["Tennis", "Human 1", "Human 2"];
app_name =["cl", "sd", "cc"];
full_app_name = ["Event Classification", "Event Detection","Cross Classification"];

train_dep_number = [24];

xlabel_name=string(train_dep_number);

cmap =[[0.4940 0.1840 0.5560];[0 0.4470 0.7410];[0.9290 0.6940 0.1250]];
pra_result =[];
rmse_result =[];
error_result=[];
cmap2 =[[0 0.4470 0.7410]; [0.3010 0.7450 0.9330]];

normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes"];
sele_app_set =[1,2];

general_rmse_result={};
general_error_result={};
total_count = 0;
for excitation_num=[2,3] % 1 tennis 2 footstep

    only_pra ={};
    only_rmse ={};
    only_error={};
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
    all_case_snr_error ={};
    all_case_ssim_error ={};
    
    for train_num= 1:length(train_dep_number)
        train_number = train_dep_number(train_num);

        mat_file_name = ['./footstep_result/two_obj_no35',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];

        
        %nor:our method pra object;  minmax; msenor: our method change to
        %mse object; bayesnor: global normal
        load(mat_file_name);
        
        tmp_case_SAR = [];
        tmp_case_SNR = [];
        tmp_case_SSIM = [];
        tmp_weight =[];
        tmp_test_case_PRA=[];
        tmp_error=[];
        tmp_snr_error=[];
        tmp_ssim_error =[];
        total_test_number=2000;
        tmp_case_test_MSE = [];
        tmp_case_SNR_test_MSE = [];
        tmp_case_SSIM_test_MSE = [];
            
        for train_case_num=1:round(total_test_number/(48-train_number))+1;
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
            
            tmp_case_SAR = [tmp_case_SAR, SAR_re];
            tmp_case_SNR = [tmp_case_SNR, SNR_re];
            tmp_case_SSIM = [tmp_case_SSIM, SSIM_re];
            %MSE
            tmp_case_test_MSE = [tmp_case_test_MSE, MSE];
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
            tmp_error = [tmp_error, lim_ssq - test_acc];
            
            %SNR error
            tmp_snr_error =NaN;  
            
            %SSIM error
            tmp_ssim_error =NaN;  
        end
        
        all_case_SAR(:, train_num) = tmp_case_SAR(1:total_test_number)';
        all_case_SNR(:, train_num) = tmp_case_SNR(1:total_test_number)';
        all_case_SSIM(:, train_num) = tmp_case_SSIM(1:total_test_number)';

        all_case_test_MSE(:, train_num) = tmp_case_test_MSE(1:total_test_number)';
        all_case_SNR_test_MSE(:, train_num) = tmp_case_SNR_test_MSE(1:total_test_number)';
        all_case_SSIM_test_MSE(:, train_num) = tmp_case_SSIM_test_MSE(1:total_test_number)';
        test_case_PRA(train_num,:) = nanmean(tmp_test_case_PRA);
        
        %error
        all_case_error(:,train_num)=tmp_error(1:total_test_number)';
        all_case_snr_error(train_num) = {NaN};%{tmp_snr_error(1:total_test_number)};
        all_case_ssim_error(train_num) ={NaN};%{tmp_ssim_error(1:total_test_number)}; 

    end
    
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
    
    %RMSE
    mean_RMSE = [mean(all_case_test_MSE)', mean(all_case_SNR_test_MSE)', mean(all_case_SSIM_test_MSE)'];
    std_RMSE = [std(all_case_test_MSE)', std(all_case_SNR_test_MSE)', std(all_case_SSIM_test_MSE)'];
    fi=figure
    set(gcf,'position',[300 100 700 330] );
    bar(train_dep_number,mean_RMSE);
    hold on
    errorbar(train_dep_number-0.2, mean_RMSE(:,1), std_RMSE(:,1),'ok');
    errorbar(train_dep_number-0, mean_RMSE(:,2), std_RMSE(:,2),'ok');
    errorbar(train_dep_number+0.2, mean_RMSE(:,3), std_RMSE(:,3),'ok');
    xticks(train_dep_number)
    xticklabels(xlabel_name);
    title([char(full_exc_name(excitation_num)),'   ', char(full_app_name(app_num))])
    legend('Our method', 'SNR', 'SSIM','location', 'best','Orientation','horizontal');
    ylim([0 0.5])
    ylabel('RMSE')
    err_loc =[-0.5,0,0.5];
    for xx=1:size(mean_RMSE,1)
    for yy=1:size(mean_RMSE,2)
        tmp_x = train_dep_number(xx)+err_loc(yy);
        text(tmp_x, mean_RMSE(xx,yy)+0.02, num2str(mean_RMSE(xx,yy),'%.2f'),'vert','bottom','horiz','center');
    end
    end
    figue_name =['./figures/',char(exc_name(excitation_num)),'_',char(full_app_name(app_num)), '_train_size_rmse.jpg'];
    %saveas(fi, figue_name);
    
    only_pra{app_num} = all_case_SAR;
    only_rmse{app_num} = all_case_test_MSE;
    only_error{app_num} = all_case_error;
    
    total_count = total_count +1;
    general_rmse_result{total_count}=all_case_test_MSE;
    general_error_result{total_count}=all_case_error;

end


%{
    %RMSE
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
    xlim([train_dep_number(1)-0.5 train_dep_number(end)+0.5])
    xlabel('The Number of Training Deployments');
    ylabel('RMSE    ')
    %ylim([0 0.25])
    
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_rmse.jpg'];
    %saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_rmse.fig'];
    %saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_rmse.eps'];
    %saveas(fi, figue_name, 'epsc');
    
    %% error
    fi = figure
    class= only_error{1};
    if app_num ==2
        sig_det = only_error{2};
    else
        sig_det = only_error{3};
    end
    
    num_cl =NaN(1000, length(class));
    num_sg = NaN(1000, length(class));
    for case_n=1:length(class)
        tmp_re = class{case_n}
        tmp_re2 = sig_det{case_n};
        num_cl(1:length(tmp_re),case_n) = tmp_re;
        num_sg(1:length(tmp_re2),case_n) = tmp_re2;
    end
    class = num_cl;
    sig_det = num_sg;
    
    set(gcf,'position',[300 100 600 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)

    fin_re = cat(1, reshape(class, [1 size(class)]),reshape(sig_det, [1 size(sig_det)]));
    aboxplot(fin_re, 'labels', train_dep_number,'colormap', cmap2);
    xticklabels(xlabel_name);
    legend('Event Classification', 'Event Detection','location', 'best','Orientation','horizontal');
    
    xlabel('The Number of Training Deployments');
    ylabel('Error')
    %ylim([0 0.25])
    
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_error.jpg'];
    %saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_error.fig'];
    %saveas(fi, figue_name);
    figue_name =['./figures/',char(exc_name(excitation_num)),'_train_size_error.eps'];
    %saveas(fi, figue_name, 'epsc');
%}
end
      
%% RMSE
%{
fi =figure
set(gcf,'position',[300 100 700 400] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
cmap2 =[[0.6350 0.0780 0.1840];[0 0.4470 0.7410] ];
%set(gcf,'position',[300 300 600 480] );
for app_num=1:2
    subplot(2,1, app_num);

    %tennis = general_rmse_result{app_num};
    human1 = general_rmse_result{app_num};
    human2 = general_rmse_result{length(sele_app_set)+app_num};

    mean_re = [sqrt(mean(human1))', sqrt(mean(human2))'];
    std_re =[std(human1)', std(human2)'];
    
    bar_handle=bar(train_dep_number,mean_re);
    set(bar_handle(1),'FaceColor',cmap(1,:))
    set(bar_handle(2),'FaceColor',cmap(2,:))
    hold on
    errorbar(train_dep_number-1.5, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar(train_dep_number+1.5, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    
    xticks(train_dep_number)
    xticklabels(xlabel_name);
    legend('Tennis','Human1',  'Human2', 'location', 'south', 'Orientation','horizontal');
    xlabel('The Number of Training Deployments')
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
    ylim([0 0.22])
    
    %{
    tmp_loc=[-0.15, 0.15]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        text(tmp_x, mean_re(xx,yy)+std_re(xx,yy), num2str(mean_re(xx,yy),'%.3f'),'vert','bottom','horiz','center');
    end
    end
    %}
        set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))
end
figue_name =['./figures/human_variance_rmse.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/human_variance_rmse.fig'];
saveas(fi, figue_name);
figue_name =['./figures/human_variance_rmse.eps'];
saveas(fi, figue_name, 'epsc');


%% Error
fi =figure
set(gcf,'position',[300 100 700 400] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
cmap2 =[[0.6350 0.0780 0.1840];[0 0.4470 0.7410] ];
%set(gcf,'position',[300 300 600 480] );
for app_num=1:2
    subplot(2,1, app_num);

    %tennis = general_rmse_result{app_num};
    human1 = general_error_result{app_num};
    human2 = general_error_result{length(sele_app_set)+app_num};

    mean_re = [mean(abs(human1))', mean(abs(human2))'];
    std_re =[std(abs(human1))', std(abs(human2))'];
    
    bar_handle=bar(train_dep_number,mean_re);
    set(bar_handle(1),'FaceColor',cmap(1,:))
    set(bar_handle(2),'FaceColor',cmap(2,:))
    hold on
    errorbar(train_dep_number-1.5, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar(train_dep_number+1.5, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    
    xticks(train_dep_number)
    xticklabels(xlabel_name);
    legend('Tennis','Human1',  'Human2', 'location', 'south', 'Orientation','horizontal');
    xlabel('The Number of Training Deployments')
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
    ylim([0 0.22])
    
    %{
    tmp_loc=[-0.15, 0.15]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        text(tmp_x, mean_re(xx,yy)+std_re(xx,yy), num2str(mean_re(xx,yy),'%.3f'),'vert','bottom','horiz','center');
    end
    end
    %}
        set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))
end
figue_name =['./figures/human_variance_error.jpg'];
%saveas(fi, figue_name);
figue_name =['./figures/human_variance_error.fig'];
%saveas(fi, figue_name);
figue_name =['./figures/human_variance_error.eps'];
%saveas(fi, figue_name, 'epsc');
%}

%% Error 40 training
fi =figure
set(gcf,'position',[300 100 800 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
cmap2 =[[0.6350 0.0780 0.1840];[0 0.4470 0.7410] ];
%set(gcf,'position',[300 300 600 480] );


    %tennis = general_rmse_result{app_num};
    %classification
    human1_cl = general_error_result{1};
    human2_cl = general_error_result{length(sele_app_set)+1};
        
    human1_de = general_error_result{2};
    human2_de = general_error_result{length(sele_app_set)+2};
    %40 training
    
    human1=[human1_cl(:,end), human1_de(:,end)];
    human2=[human2_cl(:,end), human2_de(:,end)];

    mean_re = [mean(abs(human1))', mean(abs(human2))'];
    std_re =[std(abs(human1))', std(abs(human2))'];
    
    bar_handle=bar(mean_re,'BarWidth', 0.7);%[[0 0.4470 0.7410]; [0.3010 0.7450 0.9330]]
    set(bar_handle(1),'FaceColor',[0 0.4470 0.7410],'facealpha',.8,'edgecolor','k','linewidth',1.5)
    set(bar_handle(2),'FaceColor',[0 0.4470 0.7410], 'facealpha',.2,'edgecolor','k','linewidth',1.5)
    hold on
    errorbar([1:2]-0.15, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar([1:2]+0.15, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    
    xticks([1 2])
    xticklabels(["Event Classification", "Event Detection"]);
    h = legend('Human #1',  'Human #2', 'location', 'north','Fontsize',12);
    rect = h.Position;
    rect(2)= rect(2)-0.05;
    set(h, 'Position', rect)
    xlabel('Sensing Task')
    %title('Human variance')
    ylabel('Absolute Error')
    %yticks([0, 0.25, 0.5, 0.75, 1])
    ylim([0 0.2])
    %legend boxoff  
    
    tmp_loc=[-0.15, 0.15]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    %}
        set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    %title(char(full_app_name(app_num)))

figue_name =['./figures/human_variance_error.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/human_variance_error.fig'];
saveas(fi, figue_name);
figue_name =['./figures/human_variance_error.eps'];
saveas(fi, figue_name, 'epsc');