function recall_test_train_case_generate_save()

% 7 select 2 for test
dep_num = reshape(1:28, 4,[])';

recall_train=[];
recall_test=[];
for dep1=1:6
    for dep2=dep1+1:7
        tmp_test = [dep_num(dep1,:), dep_num(dep2,:)];
        tmp_train=1:28;
        tmp_train(tmp_test)=[];
        recall_train = [recall_train; tmp_train];
        recall_test = [recall_test; tmp_test];
    end
end

save('recall_test_train_set.mat', 'recall_train', 'recall_test');

end
    