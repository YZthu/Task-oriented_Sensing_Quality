clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge"];
later_part ="_footstep_SE.mat";
obj_name=["Y_S1","Y_S2","Y_S3","K_S1","K_S2","K_S3"];
select_path=[1,2,3,7,8,9,13,14,15];
for scenario = [1,2,3]
    file_name = ['./',char(deployment_name(scenario)), char(later_part)];
    load(file_name);

    for sen=1:4
        csv_name = ['./footstep_csv/', char(deployment_name(scenario)), '_', num2str(sen),'.csv'];
        
        all_sig =[];
        all_class=[];
        for tmp_obj_num = 1:length(obj_name)
            eval(['tmp_cell_set = ', char(obj_name(tmp_obj_num)),'_ftst;'])

            
            for path_n=1:length(select_path)
                path = select_path(path_n);
                tmp_path = tmp_cell_set{path};
                tmp_set = cell2mat(tmp_path{sen});
                if size(tmp_set,1)<1
                    continue;
                end
                for kk=1:size(tmp_set,1)
                    tmp_signal = tmp_set(kk,:);
                    if isnan(tmp_signal(1))
                        continue;
                    end
                    %fft
                    nor_sig = tmp_signal ./ sqrt(sum(tmp_signal.^2));
                    fft_sig = fft(nor_sig, 6500);
                    half_fft = abs(fft_sig(1:3250));
                    all_sig = [all_sig; half_fft];
                    all_class =[all_class, obj_name(tmp_obj_num)];
                end
            end

        end
        re=table(all_class', all_sig);
        writetable(re,csv_name);

    end
    
end