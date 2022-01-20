clear all
close all
clc;

exc_name =["tennis", "footstep"];
full_exc_name=["Standard Excitation", "Human Excitation"];
app_name =["cl", "sd", "cc"];
full_app_name = ["Event Classification", "Event Detection", "Cross Classification"];
train_dep_number =[24];
%full_app_name = ["classification", "signal detection"]

result_all={};
all_test_rmse={};
all_train_rmse={};

count = 0;
cmap = [[0.4940 0.1840 0.5560];[0.4660 0.6740 0.1880]]

normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes"];

for excitation_num=2 % 1 tennis 2 footstep
    %fi = figure
    %set(gca,'Fontsize',12);
    %set(gcf,'position',[300 300 600 230] );
    exc_re={};
for app_num=[1,2]        % 1 cl classification 2 sd signal detection

    all_case_SAR =[];
    all_case_SNR = [];
    all_case_SSIM = [];
    
    for train_num= 1:length(train_dep_number)
        train_number = train_dep_number(train_num);

        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/fa_',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];
        load(mat_file_name);
        
        tmp_case_SAR = [];
        tmp_case_BTL = [];
        tmp_test_rmse =[];
        for train_case_num=1:round(2000/(48-train_number))+1
            eval(['tmp_re = case_', num2str(train_case_num), ';'])
            SAR_re = tmp_re.each_fator_com_result;
            BTL_re = tmp_re.BTL_acc;
            tmp_case_SAR(train_case_num,:) = mean(SAR_re,2)';
            tmp_case_BTL(train_case_num,:) = mean(BTL_re,2)';
            
            test_mse = tmp_re.test_mse;
            train_mse = tmp_re.train_mse;
            
            test_ssq = tmp_re.test_ssq;
            test_acc = tmp_re.test_acc;
            
            test_rmse =[];
            train_rmse =[];
            for kk=1:length(test_mse)
                tmp_test_ssq = test_ssq{kk};
                tmp_test_acc = test_acc{kk};
                case_test_rmse = abs(tmp_test_ssq - tmp_test_acc);
                test_rmse(:,kk) = mean(case_test_rmse); %mean of multiple algorithm
            end
            tmp_case_SAR(train_case_num,:) = mean(SAR_re,2)';
            %tmp_test_rmse(train_case_num,:) = test_rmse';
            tmp_test_rmse = [tmp_test_rmse; test_rmse];
            %tmp_train_rmse(train_case_num,:) = train_rmse';
        end
        
        all_case_SAR = tmp_case_SAR;
        all_case_BTL = tmp_case_BTL;
        all_case_test_rmse = tmp_test_rmse%(1:2000,:);
        %all_case_train_rmse = tmp_train_rmse;
    end

    count = count +1;
    result_all(count)={all_case_SAR};
    exc_re(app_num) = {all_case_SAR};
    all_test_rmse(count)={all_case_test_rmse};
    %all_train_rmse(count)={all_case_train_rmse};
    %{
    fin_re =cat(1,reshape(all_case_SAR, [1 size(all_case_SAR)]));%, reshape(all_case_BTL,[1 size(all_case_BTL)]) );
    aboxplot(fin_re, 'labels',[ "DR", "IA", "DFC", "Hm", "ECB1", "ECB2", "ECB3", "Decay \newlineModel", "Freq. \newlineResp. \newlineModel", "All(ASQ)"]);
    legend('ASQ', 'location', 'best')
    xlabel('Assessment Factor and Model')
    title([char(full_app_name(app_num))])
    ylabel('Pairwise Rank Accuracy')
    ylim([0 1])
    yticks([0, 0.25, 0.5, 0.75, 1])
    %}
end
end


%% RMSE
color_set=[[0 0.4470 0.7410]; [0.3010 0.7450 0.9330]];
for excitation_num=1 % 1 tennis 2 footstep
    fi = figure
    %set(gca,'Fontsize',12);
    set(gcf,'position',[300 300 800 230] );
    
    all_cl = all_test_rmse{2*(excitation_num-1)+1};
    all_sd = all_test_rmse{2*(excitation_num-1)+2};
    
    
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    cl = all_cl(:,1:5);
    sd = all_sd(:,1:5);
    %cl = [cl, all_cl(:,end)];
    %sd = [sd, all_sd(:,end)];
    mean(cl)
    mean(sd)

    %fin_re = cat(1,reshape(cl, [1 size(cl)]), reshape(sd, [1 size(sd)]));
    %aboxplot(fin_re, 'labels',[ "AF_1", "AF_2", "AF_3", "AF_4", "AF_5"],'colormap', color_set);
    %
    mean_re = [mean(cl)', mean(sd)'];
    std_re =[std(cl)', std(sd)'];
    bar_handle=bar(mean_re);
    %set(bar_handle(1),'FaceColor',color_set(1,:))
    %set(bar_handle(2),'FaceColor',color_set(2,:))
        set(bar_handle(1),'FaceColor',color_set(1,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    set(bar_handle(2),'FaceColor',color_set(2,:),'facealpha',.7,'edgecolor','k','linewidth',1.5)
    hold on
    errorbar([1:5]-0.15, mean_re(:,1), std_re(:,1), 'ok','LineWidth', 1);
    hold on
    errorbar([1:5]+0.15, mean_re(:,2), std_re(:,2), 'ok','LineWidth', 1);
    xticks([1:5])
    xticklabels(["AF_1", "AF_2", "AF_3", "AF_4", "AF_5"]);
        
    tmp_loc=[-0.15, 0.15]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = xx+tmp_loc(yy);
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy)+std_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    
    le= legend('Event Classification', 'Event Detection',  'location', 'best', 'Orientation','horizontal','Fontsize',12);
    le.Position = [0.1772 0.8024 0.4445 0.1080];
    xlabel('Assessment Factor')
    %title([char(full_exc_name(excitation_num))])
    ylabel('Absolute Error')    
    ylim([0 0.25])
    yticks([0, 0.05:0.05:0.25])
        set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    figue_name =['./figures/footstep_factor_efficiency_err.jpg'];
    saveas(fi, figue_name);
    figue_name =['./figures/footstep_factor_efficiency_err.fig'];
    saveas(fi, figue_name);
    figue_name =['./figures/footstep_factor_efficiency_err.eps'];
    saveas(fi, figue_name,'epsc');
end