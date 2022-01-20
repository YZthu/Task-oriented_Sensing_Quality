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

%%
fi =figure
set(gcf,'position',[300 100 800 400] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    re = detection_F1_score;
    re([41,42,47,48]) =[];
    sig_det = reshape(re,4,[]);
    
    re = mean(classification_accuracy);
    re(:,[41,42,47,48]) = [];
    class = reshape(re, 4, []);
    %fin_re =cat(1,reshape(class, [1 size(class)]), reshape(sig_det, [1 size(sig_det)]));
    fin_re =cat(1, reshape(sig_det, [1 size(sig_det)]));
    color_set=[[0 0.4470 0.7410]; [0.3010 0.7450 0.9330]];
    aboxplot(fin_re,'colormap', color_set(1,:), 'orientation', 'horizontal');
        %le = legend('Event Classification', 'Event Detection','location', 'north','Fontsize',12);
    %set(le, 'Position', [0.5211 0.2284 0.2388 0.2008])
    %legend boxoff
    ylim([0 1])
    xlabel('Deployment ID')
    ylabel('F1 score')
    
figue_name =['./figures/deployment_environment_acc.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/deployment_environment_acc.fig'];
saveas(fi, figue_name);
figue_name =['./figures/deployment_environment_acc.eps'];
saveas(fi, figue_name, 'epsc');

%%
fi =figure
set(gcf,'position',[300 100 800 230] );
    set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    
    re = classification_accuracy;
    re(:,[41,42,47,48]) = [];
    mean_re =[];
    std_re = [];
    offset=-0.3:0.1:0.5
    for algo=1:8
        class = reshape(re(algo,:), 4, []);
        tmp_mean_re = mean(class);
        tmp_std_re = std(class);
        mean_re(algo,:) = tmp_mean_re;
        std_re(algo,:) = tmp_std_re;
        xx = 1:11;
        xx = xx + offset(algo);
        %plot(xx, tmp_mean_re);
        hold on
        %errorbar(xx, tmp_mean_re, tmp_std_re, 'ok','LineWidth', 1);
    end
   
    mean_re = mean_re';
    std_re = std_re';
    color_set=[[0 0.4470 0.7410]; [0.3010 0.7450 0.9330]];
    bar_handle=bar(mean_re, 'barwidth',0.7);
    for algo=1:8
     %   errorbar([1:11], mean_re(:,algo), std_re(:,algo), 'ok','LineWidth', 1);
    end
    
    str = ["LSVM", "RSVM", "Random Forest", "Logistic Regression", ...
        "Gaussian Naive Bayes", "XG-Boost", "K-NN", "Extra Trees"];
[h, object_h] = columnlegend(3,str,'fontname','Times New Roman','Fontsize',12,'Location', 'north');
%legend('Random Selection','Greedy','\epsilon-Greedy, \epsilon = 0.1',...
 %   '\epsilon-Greedy, \epsilon = 0.3','Thompson Sampling','Location','best', 'orientation','Horizontal')
 hold on
 %rectangle('Position',[1 0.844 98 0.015],'LineWidth',1.5)
 
    set(h, 'Position', [0.1809 0.2830 0.7313 0.6738])
    legend boxoff
    ylim([0 1])
    xlabel('Deployment ID')
    ylabel('Classification F1 score')
        set(gca,'Fontsize',12);
    set(gca, 'LineWidth',1.5)
    box on
figue_name =['./figures/classification_algo_acc.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/classification_algo_acc.fig'];
saveas(fi, figue_name);
figue_name =['./figures/classification_algo_acc.eps'];
saveas(fi, figue_name, 'epsc');