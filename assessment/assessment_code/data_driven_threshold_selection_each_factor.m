function final_th = data_driven_threshold_selection_single_fa(training_factor, train_acc)

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

final_th =[];
final_best =[];
for tmp_fa = 1:size(training_factor,2)
    tmp_fa_th =[];
    count = 0;
    for up_ind = 1:length(pencent_str)
        for low_ind = 1:length(pencent_str)
            tmp_up_val = up_band_val(up_ind, tmp_fa);
            tmp_low_val = low_band_val(low_ind, tmp_fa);
            tmp_fa_val = [tmp_low_val, tmp_up_val]';
            count = count +1;
            tmp_fa_th(:, count) = tmp_fa_val;
        end
    end
    eval(['fact_',num2str(tmp_fa) '= tmp_fa_th;'])
end

each_fact_com = length(pencent_str)*length(pencent_str);
all_for_num =(each_fact_com)^(size(training_factor,2)); 
initial_th = [sort_factors(1,:); sort_factors(end,:)];


best_threshold =[];

for tmp_fa = 1:size(training_factor, 2)

    eval(['tmp_fa_th = fact_', num2str(tmp_fa), ';'])
    best_pra =0;
    best_pra = 100;
    %best_std = 0;
    for val_idx=1:size(tmp_fa_th,2)
        th_combin = tmp_fa_th(:, val_idx);

    
            %crss validation
            cross_gr= randperm(size(training_factor,1));
            each_set = buffer(cross_gr,5);
            all_pra =[];
            for cross_num=1:5
                cross_dep_idx = each_set(cross_num,:);
                cross_dep_idx(find(cross_dep_idx==0))=[];

                cross_dep = cross_dep_idx;
                after_cross_dep = 1:size(training_factor,1);
                after_cross_dep(cross_dep_idx)=[];

                raw_train_Met = training_factor(:,tmp_fa);
                [~, nor_Met] = threshold_normalization(raw_train_Met, th_combin);
                selected_factor = nor_Met;
                add_offset_factor = [selected_factor, ones(size(selected_factor,1),1)];

                [SAR_relative_rank_acc, SAR_weight, test_mse] = SAR_assessment(train_acc, add_offset_factor, ...
                    after_cross_dep, cross_dep);
                %all_pra = [all_pra, mean(SAR_relative_rank_acc)];
                all_pra = [all_pra, mean(test_mse)];
            end
            %if mean(all_pra) > best_pra
            if mean(all_pra) < best_pra
                best_pra = mean(all_pra);
                best_fa_threshold = th_combin;
                best_std = std(all_pra);
            else
                if mean(all_pra) == best_pra
                    if std(all_pra)< best_std
                        best_pra = mean(all_pra);
                        best_fa_threshold = th_combin;
                        best_std = std(all_pra);
                    end
                end
            end
    end
    best_threshold(:, tmp_fa) = best_fa_threshold;
end
    final_th = best_threshold;
end

