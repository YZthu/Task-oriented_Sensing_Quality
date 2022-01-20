clear all
close all
clc;

exc_name =["tennis", "footstep"];
full_exc_name=["Standard excitation", "Human excitation"];
app_name =["cl", "sd", "cc"];
full_app_name = ["Event Classification", "Event Detection"];
train_dep_number =[24];
%full_app_name = ["classification", "signal detection"]

all_re={};
all_test_rmse={};
all_train_rmse={};
count = 0;
cmap=[[100 100 100]/255;[0.4660 0.6740 0.1880]];

normalization_flag = 5% 1 minmax 2 local 3 global
nor_mat_name=["_minmax", "_nor", "_globalnor","_localnor","_gradientdes","_partGD","_BTL"];
weight_name=["same_weight","same_weight_minmax","SW"];
for weight_method=[3,4]
    excitation_num=2 % 1 tennis 2 footstep

for app_num=1:2        % 1 cl classification 2 sd signal detection

    all_case_SAR =[];
    all_case_test_rmse =[];
    all_case_train_rmse = [];
    for train_num= 1:length(train_dep_number)
        train_number = train_dep_number(train_num);

        if weight_method < 4
        mat_file_name = ['./',char(exc_name(excitation_num)),'_result/weight_', char(weight_name(weight_method)),'_',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];%nor %msenor
        else
            mat_file_name = ['./',char(exc_name(excitation_num)),'_result/train_size_no35',char(exc_name(excitation_num)),...
            '_', char(app_name(app_num)),'_train_',num2str(train_dep_number(train_num)), char(nor_mat_name(normalization_flag)),'.mat'];
        end
        load(mat_file_name);
        
        total_test_number = 200;
        tmp_case_error=[];
        tmp_weight =[];
        for train_case_num=1:round(total_test_number /(48-train_number))+1
            eval(['tmp_re = case_', num2str(train_case_num), ';'])

            %Error
            test_ssq = tmp_re.test_ssq;
            test_acc = tmp_re.test_acc;
            lim_ssq = test_ssq;
            tmp_loc = find(lim_ssq>1);
            %lim_ssq(tmp_loc)=1;
            tmp_loc = find(lim_ssq<0);
            %lim_ssq(tmp_loc)=0;
            current_lim_error = lim_ssq - test_acc;
            tmp_case_error = [tmp_case_error, current_lim_error];
            
        end
        
        all_case_error(:,train_num)=tmp_case_error(1:total_test_number)';
    end
    count = count +1;
    all_re(count)={all_case_error};
    
end

end

%% error boxplot
all_result = all_re;
fi=figure
set(gcf,'position',[300 100 800 230] );
set(gca,'Fontsize',12);
set(gca, 'LineWidth',1.5)

mean_re =[];
std_re =[];
for app_num=1:2
fin_re =[];
t_mean_re=[];
t_std_re=[];
for tmp_n = app_num:2:length(all_result)
    tmp_re = all_result{tmp_n};
    t_mean_re=[t_mean_re, nanmean(abs(tmp_re))'];
    t_std_re =[t_std_re, nanstd(abs(tmp_re))'];
end
mean_re =[mean_re, t_mean_re'];
std_re = [std_re, t_std_re'];
end
    %fin_re =cat(1,reshape(tennis, [1 size(tennis)]), reshape(foot, [1 size(foot)]));

    train_dep_number=1:2
    b=bar(mean_re')
    set(b(1),'FaceColor',cmap(1,:), 'facealpha',.6,'edgecolor','k','linewidth',1.5)
    set(b(2), 'FaceColor',  cmap(2,:), 'facealpha',.8,'edgecolor','k','linewidth',1.5)
    %set(b(3), 'FaceColor',  cmap(3,:), 'facealpha',.8,'edgecolor','k');
    tmp_loc =[-0.14 0.14];
    hold on
    for bar_num=1:size(mean_re,2)
        errorbar(train_dep_number(bar_num)+tmp_loc, mean_re(:,bar_num), std_re(:,bar_num), 'o','LineWidth', 1,'Color','k');
        hold on
    end
    %tmp_loc =[]
    for xx=1:size(mean_re,1)
    for yy=1:size(mean_re,2)
        tmp_x = train_dep_number(yy)+tmp_loc(xx);
        bb =['(', num2str(std_re(xx,yy),'%.3f'), ')'];
        text(tmp_x, mean_re(xx,yy), {num2str(mean_re(xx,yy),'%.3f'),bb},'vert','bottom','horiz','center');
    end
    end
    
    %aboxplot(fin_re, 'labels', train_dep_number,'colormap', cmap2(1:2,:));
    xticks([1 2])
    xticklabels({'Event Classification','Event Detection'});
    xlabel('Sensing Task');
    %title('Weight Selection Strategy')
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    ylabel('Absolute Error')
    ylim([0 0.5])

le=legend('Equal Weight (Baseline 4)', 'Task Oriented (AutoQual)','location', 'north','Fontsize',12);
tml = le.Position;
tml(1) = tml(1)-0.05;
tml(2) = tml(2)+ 0;
le.Position = tml;
%legend boxoff
figue_name =['./figures/weight_efficiency.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/weight_efficiency.fig'];
saveas(fi, figue_name);
figue_name =['./figures/weight_efficiency.eps'];
saveas(fi, figue_name, 'epsc');