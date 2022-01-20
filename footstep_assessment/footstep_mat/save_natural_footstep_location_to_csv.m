clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
later_part ="_footstep_normal_location_SE.mat";
obj_name=["Y_S2","Y_S3","K_S2","K_S3"];
select_path=1:18;
for scenario = [8:10]
    file_nam = ['./',char(deployment_name(scenario)), char(later_part)];
    load(file_nam);

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
        csv_name = ['./normal_footstep_location_csv/', char(deployment_name(scenario)), '_', num2str(sen),'.csv'];
        
        all_sig =[];
        all_location=[];
        all_class=[];
        for tmp_obj_num = 1:length(obj_name)
            eval(['tmp_cell_set = ', char(obj_name(tmp_obj_num)),'_', num2str(sen),'_allst;'])
            for path_n=1:length(tmp_cell_set)
                path = select_path(path_n);
                tmp_set = tmp_cell_set{path};
                if size(tmp_set,1)<1
                    continue;
                end
                if size(tmp_set,1) ~= 8
                    e='ee';
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
                    if mod(path_n,2)
                        all_location =[all_location, kk];
                    else
                        all_location =[all_location, 9-kk];
                    end
                end
            end

        end
        re=table(all_class', all_location', all_sig);
        writetable(re,csv_name);

    end
    
end