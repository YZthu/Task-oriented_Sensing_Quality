%save the classification accuracy of the basement and wooden plank

Acc_M1 =[
0.590779221	0.4375	0.497112181
0.612532468	0.45	0.478119215
0.623766234	0.491666667	0.456386524
0.554480519	0.466666667	0.505331359
1	1	1
0.297142857	0.341666667	0.357978526
1	1	1
0.474480519	0.279166667	0.251536468
0.594545455	0.525	0.510921881

];

Acc_M2 = [
0.58	0.471589537	0.528205128
0.606666667	0.423661972	0.48974359
0.596666667	0.437947686	0.487179487
0.616666667	0.457384306	0.523076923
1	1	1
0.34	0.321851107	0.341025641
1	1	1
0.46	0.296861167	0.292307692
0.61	0.471549296	0.5

];

Acc_M3 =[
0.605555556	0.496676587	0.532104455
0.55	0.496775794	0.451766513
0.508333333	0.51577381	0.506707629
0.577777778	0.468501984	0.522529442
1	1	1
0.252777778	0.39280754	0.346031746
1	1	1
0.480555556	0.35828373	0.179365079
0.538888889	0.509424603	0.483922171

];

Acc_M4 =[
0.669607843	0.352560976	0.556597222
0.663512361	0.328536585	0.506448413
0.599488491	0.357682927	0.455555556
0.657885763	0.357926829	0.562896825
1	1	1
0.283375959	0.333414634	0.33015873
1	1	1
0.593734015	0.240731707	0.286507937
0.637340153	0.338170732	0.49360119

];


save('footstep_classification_dep', 'Acc_M1', 'Acc_M2', 'Acc_M3', 'Acc_M4');
all_acc =[];
for dep_c =1:size(Acc_M1,2)
    all_acc =[all_acc, Acc_M1(:,dep_c)];
    all_acc =[all_acc, Acc_M2(:,dep_c)];
    all_acc =[all_acc, Acc_M3(:,dep_c)];
    all_acc =[all_acc, Acc_M4(:,dep_c)];
end
all_acc(7,:)=[];
all_acc(5,:)=[];
%%
figure
plot(all_acc', 'linewidth',2);
%la =["Linear\newlineSVM", "RBF\newlineSVM", "Random\newlineForest", "    Logistic\newlineRegression",...
%     "AdaBoost","Naive\newlineBayes", "XGBoost", "k-NN","Extra\newlineTrees"];
%la =["Linear SVM", "RBF SVM", "Random Forest", "    Logistic Regression",...
%     "AdaBoost","Naive Bayes", "XGBoost", "k-NN","Extra Trees"];
la =["Linear SVM", "RBF SVM", "Random Forest", "Logistic Regression",...
     "Naive Bayes",  "k-NN","Extra Trees"];
legend(la);
xlabel('Deployment');
ylim([0 1])