clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
later_part ="_footstep_normal_SE.mat";
obj_name=["Y_S1","Y_S2","Y_S3","K_S1","K_S2","K_S3"];
select_path=[1,2,3,7,8,9,13,14,15];
for scenario = [10,11]
    select_path=[1,2,3,7,8,9,13,14,15];
    file_nam = ['./',char(deployment_name(scenario)), char(later_part)];
    load(file_nam);
    if scenario ==2
        select_path = [select_path, [4,10,16]];
    end
    if scenario ==8
        select_path=[1,2,3,4,5,7,8,9,10,11];
    end

    sensor_number=4;
    if scenario > 9
        sensor_number = 6;
    end
    for sen=1:sensor_number
        
        if scenario ==10 | scenario==11
            if sen ==6
                select_path=1:18;
            end
        end
        %csv_name = ['./normal_footstep_csv/', char(deployment_name(scenario)), '_', num2str(sen),'.csv'];
        
        all_sig =[];
        all_class=[];
        for tmp_obj_num = 1:length(obj_name)
            eval(['tmp_cell_set = ', char(obj_name(tmp_obj_num)),'_', num2str(sen),'_ftst;'])

            
            for path_n=1:length(select_path)
                path = select_path(path_n);
                tmp_set = tmp_cell_set{path};
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
        %writetable(re,csv_name);

    end
    
end