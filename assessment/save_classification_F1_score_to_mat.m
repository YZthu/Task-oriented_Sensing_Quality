%save the classification accuracy of the basement and wooden plank

Acc_M1 =[
0.985	0.98	0.97
0.855	0.99	0.995
0.895	0.97	0.965
0.99	0.96	0.93
0.75	0.555	0.745
0.85	0.925	0.93
0.875	0.96	0.935
0.99	0.925	0.975
0.88	0.965	0.975


];

Acc_M2 = [
1	    1	    0.985
0.85	0.995	0.98
0.955	0.965	0.98
1	    0.97	0.94
0.765	0.76	0.82
0.90	0.905	0.905
0.935	0.985	0.95
1.0 	0.96	0.97
0.955	0.965	0.985

];

Acc_M3 =[
0.99	0.959114959	0.99
0.895	0.886964887	0.99
0.945	0.949013949	0.995
0.995	0.908128908	0.97
0.755	0.918710919	0.815
0.895	0.908369408	0.96
0.94	0.928811929	0.99
0.99	0.78980279	0.975
0.945	0.949013949	0.985

];

Acc_M4 =[
1	    0.91	0.99
0.845	0.725	0.98
0.97	0.845	0.985
1	    0.835	0.945
0.75	0.775	0.79
0.95	0.58	0.89
0.945	0.84	0.99
1	    0.635	0.935
0.99	0.845	0.99
 
];


save('algo_9_classification_dep', 'Acc_M1', 'Acc_M2', 'Acc_M3', 'Acc_M4');
all_acc =[];
for dep_c =1:size(Acc_M1,2)
    all_acc =[all_acc, Acc_M1(:,dep_c)];
    all_acc =[all_acc, Acc_M2(:,dep_c)];
    all_acc =[all_acc, Acc_M3(:,dep_c)];
    all_acc =[all_acc, Acc_M4(:,dep_c)];
end

%%
figure
plot(all_acc', 'linewidth',2);
%la =["Linear\newlineSVM", "RBF\newlineSVM", "Random\newlineForest", "    Logistic\newlineRegression",...
%     "AdaBoost","Naive\newlineBayes", "XGBoost", "k-NN","Extra\newlineTrees"];
la =["Linear SVM", "RBF SVM", "Random Forest", "    Logistic Regression",...
     "AdaBoost","Naive Bayes", "XGBoost", "k-NN","Extra Trees"];
legend(la);
xlabel('Deployment');
ylim([0 1])