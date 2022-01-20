%save the classification accuracy of the basement and wooden plank

%location 4
Acc_M1 =[
0.875	0.9	1	0.975	0.95	1	0.475	1	1
0.875	0.9	1	0.95	0.95	0.875	0.65	0.975	1
];

Acc_M2 = [
0.85	0.975	1	0.975	0.95	0.975	0.825	1	1
0.825	0.975	1	0.975	0.925	0.975	0.8	0.975	1
];

Acc_M3 =[
0.95	0.875	1	1	0.925	0.85	0.65	0.975	1
0.95	0.725	0.975	1	0.925	0.9	0.6	0.975	1
];

Acc_M4 =[
0.975	0.675	0.975	1	0.95	0.975	0.75	1	1
0.975	0.575	0.975	1	0.9	0.975	0.675	1	1
];

ex_Acc_M1 =[
0.95	0.975
0.925	0.975  
];

ex_Acc_M2 =[
0.975	0.95
0.95	0.925  
];

ex_Acc_M3 =[
0.975	1
0.975	1
];

ex_Acc_M4 =[
0.921428571	1
0.921428571	1
];

ex_Acc_M5 =[
0.975	0.95
0.975	0.875 
];

ex_Acc_M6 =[
0.782142857	0.753571429
0.810714286	0.703571429   
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
location4 = classification_accuracy;
save('classification_acc.mat', 'location4','-append');
