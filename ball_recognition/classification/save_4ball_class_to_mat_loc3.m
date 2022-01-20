%save the classification accuracy of the basement and wooden plank

%location 1
Acc_M1 =[
0.95	0.925	1	1	1	0.925	0.95	0.975	1
0.925	0.875	1	1	1	0.871428571	0.95	0.975	1
];

Acc_M2 = [
0.95	1	1	1	1	0.975	0.7	0.975	1
0.9	1	0.975	1	1	0.975	0.675	0.975	1
];

Acc_M3 =[
0.896428571	0.975	1	0.9	0.725	0.75	0.6	0.875	0.9
0.846428571	0.975	1	0.9	0.825	0.7	0.45	0.9	0.925
];

Acc_M4 =[
1	0.875	1	0.975	0.85	0.875	0.775	0.95	0.95
0.975	0.8	1	0.975	0.9	0.925	0.7	0.95	0.925

];

ex_Acc_M1 =[
0.825	0.975
0.825	0.9   
];

ex_Acc_M2 =[
0.875	0.925
0.8	0.875 
];

ex_Acc_M3 =[
0.925	0.85
0.9	0.825   
];

ex_Acc_M4 =[
0.95	0.9
0.925	0.9 
];

ex_Acc_M5 =[
0.9	0.95
0.8	0.95  
];

ex_Acc_M6 =[
0.775	0.828571429
0.725	0.8 
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
location3 = classification_accuracy;
save('classification_acc.mat', 'location3', '-append');
