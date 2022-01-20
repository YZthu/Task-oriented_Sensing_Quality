function [relative_rank_acc,relative_rank_acc_10] = relative_rank_accuracy_eva(train_ssq, train_acc, test_ssq, test_acc)

relative_rank_acc =[];
for test_dep_num=1:length(test_ssq)
    test_dep_ssq = test_ssq(test_dep_num);
    test_dep_acc = test_acc(test_dep_num);
    
    correct_count = 0;
    for train_dep_num=1:length(train_ssq)
        tmp_train_dep_ssq = train_ssq(train_dep_num);
        tmp_train_dep_acc = train_acc(train_dep_num);
        
        acc_state = 0;
        if tmp_train_dep_acc > test_dep_acc
            acc_state =1;
        end
        
        ssq_state = 0;
        if tmp_train_dep_ssq > test_dep_ssq
            ssq_state =1;
        end
        
        if acc_state == ssq_state 
            correct_count = correct_count +1;
        end
    end
    relative_rank_acc(test_dep_num) = correct_count / length(train_ssq);
    
end

relative_rank_acc_10 =[];
ssq_gap = 0.1*(max(train_ssq) - min(train_ssq));
acc_gap = 0.1*(max(train_acc) - min(train_acc));

for test_dep_num=1:length(test_ssq)
    test_dep_ssq = test_ssq(test_dep_num);
    test_dep_acc = test_acc(test_dep_num);
    
    correct_count = 0;
    for train_dep_num=1:length(train_ssq)
        tmp_train_dep_ssq = train_ssq(train_dep_num);
        tmp_train_dep_acc = train_acc(train_dep_num);
        
        acc_state = 0;
        if abs(tmp_train_dep_acc - test_dep_acc)> acc_gap
            if tmp_train_dep_acc > test_dep_acc
                acc_state =1;
            else
                acc_state =-1;
            end
        else
            acc_state =0;
        end
        
        ssq_state = 0;
        if abs(tmp_train_dep_ssq - test_dep_ssq) > ssq_gap
            if tmp_train_dep_ssq > test_dep_ssq
                ssq_state =1;
            else
                ssq_state =-1;
            end
        else
            ssq_state = 0;
        end
        
        if acc_state == ssq_state 
            correct_count = correct_count +1;
        end
    end
    relative_rank_acc_10(test_dep_num) = correct_count / length(train_ssq);
    
end

end