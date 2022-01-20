%save the classification accuracy of the basement and wooden plank

%location 1
Acc_M1 =[
1	0.95	0.95	1	0.971428571	1	0.475	1	1
0.975	0.95	0.925	1	0.971428571	1	0.45	1	1
];

Acc_M2 = [
0.975	1	0.95	1	0.971428571	0.95	0.875	1	1
0.95	0.975	0.925	0.975	1	0.95	0.875	1	0.975
];

Acc_M3 =[
0.975	0.85	1	1	0.925	0.95	0.825	0.975	1
0.9	0.8	0.975	0.975	0.95	0.925	0.75	0.975	1
];

Acc_M4 =[
0.95	0.725	1	1	1	0.9	0.675	1	1
0.95	0.7	1	1	1	0.9	0.675	1	1
];

ex_Acc_M1 =[
0.8	0.95
0.825	0.95    
];

ex_Acc_M2 =[
0.85	0.95
0.825	0.95   
];

ex_Acc_M3 =[
0.8	0.95
0.775	0.925   
];

ex_Acc_M4 =[
0.775	1
0.9	0.925  
];

ex_Acc_M5 =[
0.825	0.95
0.8	0.95   
];

ex_Acc_M6 =[
0.657142857	0.925
0.647619048	0.9   
];

classification_accuracy = [];
for dep_num=1:9
    classification_accuracy =[classification_accuracy, Acc_M1(:, dep_num), Acc_M2(:, dep_num), Acc_M3(:, dep_num), Acc_M4(:, dep_num)];
end

ex_class_acc =[];
for dep_c =1:size(ex_Acc_M1,2)
    ex_class_acc =[ex_class_acc, ex_Acc_M1(:,dep_c)];
    ex_class_acc =[ex_class_acc, ex_Acc_M2(:,dep_c)];
    ex_class_acc =[ex_class_acc, ex_Acc_M3(:,dep_c)];
    ex_class_acc =[ex_class_acc, ex_Acc_M4(:,dep_c)];
    ex_class_acc =[ex_class_acc, ex_Acc_M5(:,dep_c)];
    ex_class_acc =[ex_class_acc, ex_Acc_M6(:,dep_c)];
end
classification_accuracy = [classification_accuracy, ex_class_acc];
location1 = classification_accuracy;
save('classification_acc.mat', 'location1');
