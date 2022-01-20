function [final_th, final_weight] = data_driven_threshold_selection_gradient_descent(training_factor, train_acc)

pencent_str =[0.1, 0.25, 0.4];

sort_factors =[];
for fact_num=1:size(training_factor,2)
    tmp_fact = training_factor(:, fact_num);
    tmp_sort = sort(tmp_fact, 'ascend');
    sort_factors(:, fact_num) = tmp_sort;
end
   
low_band_idx = floor(size(training_factor,1)*pencent_str);
up_band_idx = floor(size(training_factor,1)*(1-pencent_str));
if low_band_idx(1)==0
    low_band_idx(1) = 1;
end

low_band_val = sort_factors(low_band_idx,:);
up_band_val = sort_factors(up_band_idx,:);

%random sample
repeat_time = 50;

low_band_condidate =[];
up_band_condidate =[];
for kk=1:repeat_time
    low_bd_idx = randsample(size(low_band_val,1),size(training_factor,2),true)';
    up_bd_idx = randsample(size(low_band_val,1),size(training_factor,2),true)';
    
    tmp_low_condi =[];
    tmp_up_condi =[];
    for tmp_fa_n =1:size(training_factor,2)
    	tmp_low_condi(tmp_fa_n) = low_band_val(low_bd_idx(tmp_fa_n), tmp_fa_n);
    	tmp_up_condi(tmp_fa_n) = up_band_val(up_bd_idx(tmp_fa_n), tmp_fa_n);
    end
    low_band_condidate(kk,:)= tmp_low_condi;
    up_band_condidate(kk,:) = tmp_up_condi;
end

each_model_per=NaN(1, repeat_time);
each_model_std=NaN(1,repeat_time);
for evaluat_n = 1:repeat_time
    w0=ones(size(training_factor,2)+1,1)./size(training_factor,2);
    up_initial = up_band_condidate(evaluat_n,:);
    low_initial = low_band_condidate(evaluat_n,:);
    
    X0 =[low_initial'; up_initial'; w0];
    %crss validation
    cross_gr= randperm(size(training_factor,1));
    each_set = buffer(cross_gr,5);
    all_pra =[];
    for cross_num=1:5
        cross_dep_idx = each_set(cross_num,:);
        cross_dep_idx(find(cross_dep_idx==0))=[];

        cross_test_dep = cross_dep_idx;
        cross_train_dep = 1:size(training_factor,1);
        cross_train_dep(cross_dep_idx)=[];

        if length(cross_train_dep)< 3*size(training_factor,2)
            er='eeee';
        end
        options = optimoptions(@fmincon,'Algorithm','interior-point','Display','notify');
        options.Algorithm = 'sqp';
        [best_sol,fval,exitflag,output,lambda,grad,hessian] = fmincon(@(x)thresholdin_factor_regression(x, training_factor(cross_train_dep,:), train_acc(cross_train_dep)) ,X0,[],[],[], [],[],[],[],options);    
        low_band = best_sol(1:size(training_factor,2));
        up_band = best_sol(size(training_factor,2)+1: 2*size(training_factor,2));
        wei = best_sol(2*size(training_factor,2)+1:end);

        best_threshold =[low_band'; up_band'];
        weight = wei;

        nor_factor = sigmoid_normalization(training_factor, best_threshold);
        add_offset_factor = [nor_factor, ones(size(nor_factor,1),1)];
        SSQ = add_offset_factor*wei;
        cv_ssq = SSQ(cross_test_dep)';
        cv_acc = train_acc(cross_test_dep);

        test_mse = limited_mse(cv_ssq, cv_acc);
        all_pra = [all_pra, mean(test_mse)];
    end
    each_model_per(evaluat_n) = mean(all_pra);
    each_model_std(evaluat_n) = std(all_pra);
end
[~, best_loc] = min(each_model_per);
if length(best_loc)> 1
    std_val = each_model_std(best_loc);
    [~,std_loc] = min(std_val);
    if length(std_loc)>1
        std_loc = std_loc(1);
    end
    best_std_loc = best_loc(std_loc);
    best_loc = best_std_loc;
end
    up_initial = up_band_condidate(best_loc,:);
    low_initial = low_band_condidate(best_loc,:);
    w0=ones(size(training_factor,2)+1,1)./size(training_factor,2);
        X0 =[low_initial'; up_initial'; w0];
        best_sol = fmincon(@(x)thresholdin_factor_regression(x, training_factor, train_acc) ,X0,[],[],[], [],[],[]);    
    low_band = best_sol(1:size(training_factor,2));
    up_band = best_sol(size(training_factor,2)+1: 2*size(training_factor,2));
    wei = best_sol(2*size(training_factor,2)+1:end);
    
    final_th = [low_band'; up_band'];
    final_weight = wei;
end

