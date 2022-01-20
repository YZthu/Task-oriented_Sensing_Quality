function mse = obj_local_band_select(low_up_ba, training_factor, train_acc, final_th, current_fa_num)

cross_gr= randperm(size(training_factor,1));
each_set = buffer(cross_gr,5);
all_e =[];
all_bd = table2array(low_up_ba);

low_bd= all_bd(1:length(all_bd)/2);
up_bd = all_bd(length(all_bd)/2+1:end);

th_combin = final_th;%[low_up_band(1: szie(training_factor,2));low_up_band(szie(training_factor,2)+1:end)];
th_combin(:, current_fa_num) = [low_bd; up_bd];

[~, nor_Met] = threshold_normalization(training_factor,th_combin);
selected_factor = nor_Met;
add_offset_factor = [selected_factor, ones(size(selected_factor,1),1)];
w0=ones(size(nor_Met,2)+1,1)./size(nor_Met,2);
%weight estimation
            
            
t1 = clock; 
options = optimoptions('fmincon','Display','off');
SAR_weight = fmincon(@(x)factor_regression(x, add_offset_factor, train_acc) ,w0,[],[],[], [],[],[],[],options);
t2 = clock;
%solve = weight_gradient_descent(w0, add_offset_factor, train_acc);
t3 = clock;
%one_case_time = etime(t2,t1)
%one_case_time = etime(t3,t2)
%mse
SSQ = add_offset_factor*SAR_weight;
mse= sum((SSQ'- train_acc).^2);% + lam*sum(abs(x));

end