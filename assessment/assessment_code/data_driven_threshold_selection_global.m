function bayes_th = data_driven_threshold_selection_global(training_factor, train_acc)

min_fa_val = min(training_factor);
max_fa_val = max(training_factor);

low_me=[];
up_me=[];
for fa_num = 1:size(training_factor,2)
    eval(['F_', num2str(fa_num),'_up = optimizableVariable(''F_', num2str(fa_num),'_up'',[',num2str(min_fa_val(fa_num)),' ', num2str(max_fa_val(fa_num)),']);']);
    eval(['F_', num2str(fa_num),'_low = optimizableVariable(''F_', num2str(fa_num),'_low'',[',num2str(min_fa_val(fa_num)),' ', num2str(max_fa_val(fa_num)),']);']);
    eval(['tmp_up = F_', num2str(fa_num),'_up;']);
    eval(['tmp_low = F_', num2str(fa_num),'_low;']);
    low_me =[low_me, tmp_low];
    up_me = [up_me, tmp_up];

end
%par_name =['[', low_name, up_name, ']'];

var_me = [low_me, up_me];
fun = @(low_up_ba)obj_band_select(low_up_ba, training_factor, train_acc);
%best_threshold =bayesopt(fun, [F_1_low,F_2_low,F_3_low,F_4_low,F_5_low,F_6_low,F_7_low,F_8_low,F_9_low,F_10_low,F_1_up,F_2_up,F_3_up,F_4_up,F_5_up,F_6_up,F_7_up,F_8_up,F_9_up,F_10_up,],'UseParallel',true);
best_threshold =bayesopt(fun, var_me, 'UseParallel',false,'MaxObjectiveEvaluations', 17,'Verbose',0);

final_th = table2array(best_threshold.NextPoint);
low_bd= final_th(1:length(final_th)/2);
up_bd = final_th(length(final_th)/2+1:end);
bayes_th = [low_bd; up_bd];
end

