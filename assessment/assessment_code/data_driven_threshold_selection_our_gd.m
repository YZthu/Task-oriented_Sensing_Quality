function [final_th, final_weight] = data_driven_threshold_selection_our_gd(training_factor, train_acc,full_test_Met, test_acc)


min_val = min(training_factor);
max_val = max(training_factor);
%random sample
repeat_time = 50;
factor_dim = size(training_factor,2);

initial_point = [];
for factor_n=1:factor_dim
    diff = (max_val(factor_n) - min_val(factor_n))/100;
    tmp_cd = min_val(factor_n):diff:max_val(factor_n);
    initial_point(:, factor_n) = tmp_cd(1:100);
end

low_band_condidate =[];
up_band_condidate =[];
for kk=1:repeat_time
    
    for tmp_fn = 1:factor_dim
        re = randsample(size(initial_point,1),2,false);
        low_bd_idx(tmp_fn) = min(re);
        up_bd_idx(tmp_fn) = max(re);
    end

    tmp_low_condi =[];
    tmp_up_condi =[];
    for tmp_fa_n =1:factor_dim
        
    	tmp_low_condi(tmp_fa_n) = initial_point(low_bd_idx(tmp_fa_n), tmp_fa_n);
    	tmp_up_condi(tmp_fa_n) = initial_point(up_bd_idx(tmp_fa_n), tmp_fa_n);
    end
    low_band_condidate(kk,:)= tmp_low_condi;
    up_band_condidate(kk,:) = tmp_up_condi;
end

each_model_per=NaN(1, repeat_time);
each_model_std=NaN(1,repeat_time);
all_pra =NaN(1, repeat_time);
best_sole = NaN(repeat_time,3*factor_dim+1);

for evaluat_n = 1:repeat_time
    w0=ones(factor_dim+1,1)./factor_dim;
    up_initial = up_band_condidate(evaluat_n,:);
    low_initial = low_band_condidate(evaluat_n,:);
    
    X0 =[low_initial'; up_initial'; w0];
    %crss validation
    cross_gr= randperm(size(training_factor,1));
    each_set = buffer(cross_gr,5);
    
       
        best_sol = gradient_descent(low_initial, up_initial, w0', training_factor, train_acc,full_test_Met, test_acc);
        %low_band = best_sol(1:factor_dim);
        %up_band = best_sol(factor_dim+1: 2*factor_dim);
        %wei = best_sol(2*factor_dim+1:end)';
        re=Ojbect_function( best_sol, training_factor, train_acc);

        each_model_per(evaluat_n)= mean(re);
        each_model_std(evaluat_n) = std(re);
        best_sole(evaluat_n,:) = best_sol';
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

best_sol = best_sole(best_loc,:);
%best_sol = fmincon(@(x)thresholdin_factor_regression(x, training_factor, train_acc) ,X0,[],[],[], [],[],[]);    
low_band = best_sol(1:factor_dim);
up_band = best_sol(factor_dim+1: 2*factor_dim);

wei = best_sol(2*factor_dim+1:end);
final_th = [low_band; up_band];
%{
[fin_Met] = sigmoid_normalization(training_factor, final_th);
nor_Met = [fin_Met, ones(size(fin_Met,1),1)];
w0=ones(size(nor_Met,2),1)./size(nor_Met,2);
options = optimoptions('fmincon','Display','off');
SAR_weight = fmincon(@(x)factor_regression(x, nor_Met, train_acc) ,w0,[],[],[], [],[],[],[],options);
%}

final_weight = wei';
end

