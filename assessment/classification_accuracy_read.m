function [classification_accuracy] = classification_accuracy_read(add_path)

%file_name =[add_path, '3_location_classification_accuracy_5algo.mat'];
%file_name =[add_path, 'algo_9_classification_f1.mat'];
file_name =[add_path, 'normal_footstep_4class_classification_dep.mat'];
%file_name =[add_path, 'classification_accuracy.mat'];
load(file_name)
%support_sc = [1,3,6,7,8,9,10,11,12];

classification_accuracy = [];
for dep_num=1:9
    classification_accuracy =[classification_accuracy, Acc_M1(:, dep_num), Acc_M2(:, dep_num), Acc_M3(:, dep_num), Acc_M4(:, dep_num)];
end

load('../normal_footstep_4class_extra_2sc.mat')
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

return
%algo
algo_name = ["LinearSVM", "RBFSVM", "RandomForest", "LogisticRegression", "NaiveBayes", "XGBoost", "kNN", "ExtraTree"];
file_name =[add_path, 'normal_footstep_4class_classification_dep.mat'];
load(file_name)
load('../normal_footstep_4class_extra_2sc.mat')

save('classification_acc.mat', 'algo_name')
for algo_n = 1:length(algo_name)
    tmp_class_acc=[];
    tmp_class_acc =[ Acc_M1(algo_n, :)', Acc_M2(algo_n, :)', Acc_M3(algo_n, :)', Acc_M4(algo_n, :)'];
    extra_acc =[ex_Acc_M1(algo_n,:)', ex_Acc_M2(algo_n,:)', ex_Acc_M3(algo_n,:)', ex_Acc_M4(algo_n,:)'];
    tmp_M =[tmp_class_acc; extra_acc];
    eval([char(algo_name(algo_n)), ' = tmp_M']);
    eval(['save(''classification_acc.mat'', ''', char(algo_name(algo_n)), ''',''-append'');'])
end

end