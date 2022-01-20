%save the classification accuracy of the basement and wooden plank

ex_Acc_M1 =[
0.560908084	0.445495495
0.448062016	0.44039039
0.574307863	0.407657658
0.54662237	0.489039039
1	1
0.381949059	0.391141141
0.588925803	0.434684685
0.405758583	0.358408408
0.565559247	0.412912913

];

ex_Acc_M2 = [
0.517777778	0.539146341
0.482121212	0.485243902
0.553333333	0.480731707
0.531111111	0.534390244
1	1
0.387878788	0.358170732
0.642727273	0.440609756
0.348181818	0.352560976
0.53989899	0.470609756

];

ex_Acc_M3 =[
0.620084567	0.319663866
0.551057082	0.302521008
0.634566596	0.319495798
0.638477801	0.34302521
1	1
0.397991543	0.28487395
0.698731501	0.326386555
0.416596195	0.261344538
0.578541226	0.261680672

];

ex_Acc_M4 =[
0.527272727	0.4
0.427272727	0.357142857
0.554545455	0.321428571
0.554545455	0.407142857
1	1
0.386363636	0.3
0.536363636	0.35
0.386363636	0.307142857
0.55	0.357142857

];

ex_Acc_M5 =[
0.633434343	0.409090909
0.584545455	0.418181818
0.736161616	0.431818182
0.66020202	0.45
1	1
0.468989899	0.322727273
0.683030303	0.436363636
0.544343434	0.381818182
0.691818182	0.445454545

];
ex_Acc_M6 =[
0.555	0.36804878
0.52	0.34304878
0.475	0.313536585
0.5825	0.367926829
1	1
0.31	0.254756098
0.525	0.35804878
0.35	0.294146341
0.49	0.29402439

];
save('normal_footstep_4class_extra_2sc', 'ex_Acc_M1', 'ex_Acc_M2', 'ex_Acc_M3', 'ex_Acc_M4', 'ex_Acc_M5', 'ex_Acc_M6');
all_acc =[];
for dep_c =1:size(ex_Acc_M1,2)
    all_acc =[all_acc, ex_Acc_M1(:,dep_c)];
    all_acc =[all_acc, ex_Acc_M2(:,dep_c)];
    all_acc =[all_acc, ex_Acc_M3(:,dep_c)];
    all_acc =[all_acc, ex_Acc_M4(:,dep_c)];
    all_acc =[all_acc, ex_Acc_M5(:,dep_c)];
    all_acc =[all_acc, ex_Acc_M6(:,dep_c)];
end
%all_acc(7,:)=[];
all_acc(5,:)=[];
%%
figure
plot(all_acc', 'linewidth',2);
%la =["Linear\newlineSVM", "RBF\newlineSVM", "Random\newlineForest", "    Logistic\newlineRegression",...
%     "AdaBoost","Naive\newlineBayes", "XGBoost", "k-NN","Extra\newlineTrees"];
%la =["Linear SVM", "RBF SVM", "Random Forest", "    Logistic Regression",...
%     "AdaBoost","Naive Bayes", "XGBoost", "k-NN","Extra Trees"];
la =["Linear SVM", "RBF SVM", "Random Forest", "Logistic Regression",...
     "Naive Bayes",   "XGBoost","k-NN","Extra Trees"];
legend(la);
xlabel('Deployment');
ylabel('Classification F1 score')
ylim([0 1])