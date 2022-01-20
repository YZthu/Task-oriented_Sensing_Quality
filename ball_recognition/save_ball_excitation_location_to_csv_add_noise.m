clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
later_part ="_id_location.mat";
obj_name=["B1","B3","B4","B5"];


for scenario = [1:11]
    file_nam = ['./',char(deployment_name(scenario)), char(later_part)];
    load(file_nam);

    sensor_number=4;
    if scenario > 9
        sensor_number = 6;
    end
    for sen=1:sensor_number
        if sen ==1 | sen ==2
            select_path = 1:5;
        else
            select_path = 4:8;
        end
        
        if scenario >9
            if sen ==1 |sen ==2 | sen ==5 |sen ==6
                select_path=3:7;
            end
        end
        
        

        sig_length=[];
        for path_n=1:length(select_path)
        
            csv_name = ['./ball_1345_csv/', char(deployment_name(scenario)), '_', num2str(sen),'_',num2str(path_n) ,'.csv'];
            all_sig =[];
            all_location=[];
            all_class=[];
            for tmp_obj_num = 1:length(obj_name)
            eval(['tmp_cell_set = ', char(obj_name(tmp_obj_num)),'_', num2str(sen),'_set;'])
            
                path = select_path(path_n);
                tmp_set = tmp_cell_set{path};
                if size(tmp_set,1)<1
                    sig_length = [sig_length, 0];
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
                    
                        all_location =[all_location, path_n];
                    if kk > 9
                        break;
                    end
                end
                sig_length = [sig_length, kk];
            end
            %re=table(all_class', all_location', all_sig);
            re=table(all_class', all_sig);
            writetable(re,csv_name);
        end
        
        if min(sig_length)<8
            sig_length
            e='ee'
        end


    end
    
end