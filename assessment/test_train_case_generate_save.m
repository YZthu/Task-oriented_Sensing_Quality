function test_train_case_generate_save()

train_num_str=[4,8,12,16,20,24,28,32,36,40];
fixed_test_size = 4;
repeat_time = 2000;
count = 0;
test_set_4=[];
full_train_set =cell(1,size(train_num_str,2));

for rpt=1:repeat_time
    random_group= randperm(44);
    test_dep =random_group(1:fixed_test_size);
    training_group = random_group(fixed_test_size+1:end);
    test_set_4(rpt,:) = test_dep;
    
    %training seze select
    for train_size_num=1:size(train_num_str,2)
        tmp_train_size = train_num_str(train_size_num);
        random_train_index = randperm(length(training_group));
        tmp_train_dep_index = random_train_index(1:tmp_train_size);
        tmp_train_dep_set = training_group(tmp_train_dep_index);
        
        previous_train_set = full_train_set{train_size_num};
        new_train_set =[previous_train_set; tmp_train_dep_set];
        full_train_set{train_size_num} = new_train_set;
        re=intersect(test_dep,tmp_train_dep_set);
        if length(re)>0
            break
        end
    end
    
end

save('test_training_set_44.mat', 'test_set_4');
%re organize the training set
for train_size_num = 1:size(train_num_str,2)
    tmp_train_set = full_train_set{train_size_num};
    eval(['train_set_', num2str(train_num_str(train_size_num)), ' = tmp_train_set;']);
    eval(['save(''test_training_set_44.mat'',''train_set_', num2str(train_num_str(train_size_num)),''',''-append'');' ])
end
return;
%generate select one from 4 sensors
off_set = 0:4:35;
train_set =[];
other_two_offset = [36,42];
for rpt=1:repeat_time
    test_ind = randi(4,1, 9);
    test_dep = test_ind + off_set;
    other_two_test = randi(4,1, 2);
    other_two_dep = other_two_test + other_two_offset;
    test_dep = [test_dep, other_two_dep];
    tmp_train_set = 1:48;
    tmp_train_set(test_dep)=[];
    train_set(rpt,:) = tmp_train_set;
end
train_set_37 = train_set;
save('test_training_set.mat', 'train_set_37','-append');
    
end
    