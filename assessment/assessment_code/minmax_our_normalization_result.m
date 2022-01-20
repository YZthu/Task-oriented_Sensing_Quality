clear all
close all
clc;

exc_name =["tennis", "footstep"];
full_exc_name=["Standard Excitation", "Human Excitation"];
app_name =["cl", "sd", "cc"];
full_app_name = ["(a) Event Classification", "(b) Event Detection"];
%train_dep_number =[12,16, 20, 24, 28,32,36,40];
train_dep_number = [8,12,16,20,24]%[12,14,16,18,20,24,28,32,36,40];
%train_dep_number =[8,12,24,36,40];
xlabel_name=string(train_dep_number);

cmap =[[0.6 0.6 0.6];[0.4660 0.6740 0.1880]];
SAR_24_result =[];
SAR_rmse_result =[];
cmap2 =[[0.75 0.75 0.75] ;[0.4660 0.6740 0.1880] ];

all_pra_result ={};
all_rmse_result ={};
count = 0;

legend_name =["MinMax", "Old nor", "Global grid search", "Local grid search", "Gradient descent"]
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes"];
legend_n =[];
for nor_n=[1,5]
    excitation_num=2 % 1 tennis 2 footstep
    legend_n =[legend_n, legend_name(nor_n)];
    
    only_sar ={};
    only_sar_rmse ={};
for app_num=[1,2]        % 1 cl classification 2 sd signal detection

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

    
    for train_num= 1:length(train_dep_number)
        train_number = train_dep_number(train_num);

        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/train_size_no35',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(nor_n)),'.mat'];%test
 
        load(mat_file_name);
        
        tmp_case_SAR = [];
        tmp_case_SNR = [];
        tmp_case_SSIM = [];
        tmp_weight =[];
        tmp_test_case_PRA=[];
        tmp_error=[];
        error_result =[];
        rmse_result=[];
        tmp_case_test_MSE =[];
        dep_list =[];
        total_test_number =2000;
        for train_case_num=1:round(total_test_number /(48-train_number))+1
            eval(['tmp_re = case_', num2str(train_case_num), ';'])
            SAR_re = tmp_re.each_fator_com_result;
            SNR_re = tmp_re.SNR_acc;
            SSIM_re = tmp_re.SSIM_acc;
            BTL_re = NaN;
            MSE = tmp_re.test_mse;
            if isfield(tmp_re, 'test_ssq')
                test_ssq = tmp_re.test_ssq;
                test_acc = tmp_re.test_acc;
            else
                test_ssq = randn(32,1)';
                test_acc = randn(32,1)';
            end

            
            lim_ssq = test_ssq;
            tmp_loc = find(lim_ssq>1);
            %lim_ssq(tmp_loc)=1;
            tmp_loc = find(lim_ssq<0);
            %lim_ssq(tmp_loc)=0;
            tmp_case_error=lim_ssq - test_acc;
            if size(MSE,1)> 8
                MSE(9:end,:)=[];
                MSE = mean(MSE,1);
            end
            mse= limited_mse(test_ssq, test_acc);
            
            % deployment result
            dep_error = NaN(1,48);
            dep_error(tmp_re.test_dep) = lim_ssq - test_acc;
            dep_mse = NaN(1,48);
            dep_mse(tmp_re.test_dep) = mse;
            error_result(train_case_num,:) = dep_error;
            rmse_result(train_case_num,:) = dep_mse;
            
            bb= sum(MSE==mse);
            if bb ~= length(MSE)
                e='ee';
            end
            
            if app_num ==2
                for kk=1:length(dep_list)
                    tmp_d = dep_list(kk);
                    bb = find(tmp_re.test_dep == tmp_d);
                    if length(bb)> 0
                        %MSE(bb)= NaN;
                        %tmp_case_error(bb) = NaN;
                    end
                end
            end
            tmp_error = [tmp_error,tmp_case_error];
            tmp_weight(:, train_case_num) = NaN;%tmp_re.each_fator_com_w;
            %PRA
            tmp_case_SAR = [tmp_case_SAR, SAR_re];
            %MSE
            tmp_case_test_MSE = [tmp_case_test_MSE, MSE];

        end
        
        %figure
        %plot(nanmean(rmse_result))
        %title('MSE')
        %{
        figure
        tmp_re = nanmean(abs(error_result));
        [bb,loc] = sort(tmp_re);
        bar(bb);
        for kkk=1:length(bb)
            text(kkk-0.1, bb(kkk)+0.01, num2str(loc(kkk)));
        end
        %}
        %figure
        %plot(nanmean(abs(error_result)))
        %title('error')
        %}
        all_case_SAR(:, train_num) = tmp_case_SAR(1:total_test_number)';

        all_case_test_MSE(:, train_num) = tmp_case_test_MSE(1:total_test_number)';       
        %error result
        all_case_error(:,train_num)=tmp_error(1:total_test_number)';
    end

    count = count +1;
    all_error(count) = {all_case_error};
    %all_result(count)={all_case_test_MSE};
end
end


%% error boxplot
all_result = all_error;
fi=figure
set(gcf,'position',[300 100 800 400] );
set(gca,'Fontsize',12);
set(gca, 'LineWidth',1.5)
for app_num=1:2
fin_re =[];
mean_re=[];
std_re=[];
for tmp_n = app_num:2:length(all_result)
    tmp_re = all_result{tmp_n};
    mean_re=[mean_re, nanmean(abs(tmp_re))'];
    std_re =[std_re, nanstd(abs(tmp_re))'];
end
    %fin_re =cat(1,reshape(tennis, [1 size(tennis)]), reshape(foot, [1 size(foot)]));
    subplot(2,1,app_num);
    
    b=bar(train_dep_number, mean_re)
    set(b(1),'FaceColor',cmap(1,:), 'facealpha',.6,'edgecolor','k')
    set(b(2), 'FaceColor',  cmap(2,:), 'facealpha',.8,'edgecolor','k');
    hold on
    tmp_loc=[-0.6 0.6]
    for bar_num=1:size(mean_re,2)
        errorbar(train_dep_number+tmp_loc(bar_num), mean_re(:,bar_num), std_re(:,bar_num), 'o','LineWidth', 1,'Color','k');
        hold on
    end
    %tmp_loc =[]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = train_dep_number(xx)+tmp_loc(yy);
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    
    %aboxplot(fin_re, 'labels', train_dep_number,'colormap', cmap2(1:2,:));
    
    xlabel('The Number of Training Deployments');
    if app_num==1
        title('(a) Event Classification');
    else
        title('(b) Event Detection');
    end
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    ylabel('Absolute Error')
    ylim([0 0.4])
end
le=legend('Piecewise (Baseline 3)', 'Sigmoid (AutoQual)', 'location', 'north','Fontsize',12);
tml = le.Position;
tml(1) = 0.63;
tml(2) = 0.36;
le.Position = tml;
figue_name =['./figures/normalization_efficiency_error_box.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/normalization_efficiency_error_box.fig'];
saveas(fi, figue_name);
figue_name =['./figures/normalization_efficiency_error_box.eps'];
saveas(fi, figue_name, 'epsc');

%% error distribution 

all_result = all_error;
app_name = ["Classification", "Detection"];
fi=figure
set(gcf,'position',[300 100 800 230] );
set(gca,'Fontsize',12);
set(gca, 'LineWidth',1.5)
for app_num=1:2

    % training size 12
fin_re=[];
for tmp_n = app_num:2:length(all_result)
    tmp_re = all_result{tmp_n};
    training_size_re = tmp_re(:,1);
    fin_re =[fin_re; training_size_re'];
end
subplot(1,2, app_num)
histogram(fin_re(1,:),-0.8:.05:0.8,'facecolor',cmap(1,:),'facealpha',.6,'edgecolor','none', 'Normalization', 'probability');
hold on
histogram(fin_re(2,:),-0.8:.05:0.8,'facecolor',cmap(2,:),'facealpha',.6,'edgecolor','none','Normalization', 'probability');
hold on
%histogram(fin_re(3,:),-0.9:.02:0.9,'facecolor',cmap(3,:),'facealpha',.5,'edgecolor','none','Normalization', 'probability');
box off
ylim([0 0.17])
%axis tight
title([char(full_app_name(app_num))])
xlabel('Error');
ylabel('Percentage');
box on
set(gca,'Fontsize',12);
set(gca, 'LineWidth',1.5)
end
le = legend('Piecewise (Baseline 3)', 'Sigmoid (AutoQual)','location','northwest','Fontsize',12);
le.Position=[0.3605 0.7161 0.2608 0.1710];

%legend boxoff
figue_name =['./figures/normalization_efficiency_error_dis.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/normalization_efficiency_error_dis.fig'];
saveas(fi, figue_name);
figue_name =['./figures/normalization_efficiency_error_dis.eps'];
saveas(fi, figue_name, 'epsc');
