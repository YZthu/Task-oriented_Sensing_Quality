clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

later_part ="_tennis_path_sig_SE.mat";
dataset_path ='../tennis_path_sig';

background_bandwidth = [];
sc_p =[10, 11];
%sc_p =[12];
excit_num_str =1:30000;
h=waitbar(0,'please wait');
for sc_count = 1:2
    scenario = sc_p(sc_count);
    file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_part)];
    load(file_name);
    sensor_bandwidth =[];
        
    %later_p ="_tennis_single_excitation_factor_SE.mat"; this is the
    %previous
    later_p ="_tennis_single_excitation_rand_fa.mat";
    file_name = [char(deployment_name(scenario)), char(later_p)];
    save(file_name, 'excit_num_str');
        
    sen_number = 4;
    if scenario > 9
        sen_number =6;
    end
    
    success_count = 1;
    for excit_num_ind=1:length(excit_num_str)
        excit_number = excit_num_str(excit_num_ind);
        
        waitbar(excit_num_ind*scenario / (10*length(excit_num_str)), h, ['sce', num2str(scenario), ' exc ',...
            num2str(excit_num_ind), ' ',num2str(100*excit_num_ind*scenario / (10*length(excit_num_str))), ' %']);
    
    success_flag = zeros(1,sen_number);
    for sensor =1:sen_number
        eval(['path_set_C{', num2str(sensor), '} = path_sig_set', num2str(sensor), ';' ])
        eval(['bck_C{',num2str(sensor), '} = bck', num2str(sensor), ';']);
        eval(['raw_bck_C{', num2str(sensor),'} = raw_bck', num2str(sensor), ';']);
    end
    re =cell(1,sen_number);
    parfor sensor =1:sen_number
        path_set = path_set_C{sensor};
        bck = bck_C{sensor};
        raw_bck = raw_bck_C{sensor};
        
        %bandwidth = find_contreat_band(raw_bck(1:1000), 0.9);
        %sensor_bandwidth(sensor) = bandwidth;
        
        if sensor ==1 | sensor == 4
            distance = [3,2,1];
        else
            distance = [1,2,3];
        end
        if scenario ==11
            if sensor ==1 | sensor ==4
                distance =[1.5,0.5,0.5];
            else
                distance = [1,2,3];
            end
        end
        
        %excitation select
        new_path_set = {};
        for path_num=1:length(path_set)
            tmp_set = path_set{path_num};
            if isnan(tmp_set(1))
                selected_sig = NaN;
            else
                tmp_exc = randperm(size(tmp_set,1));
                selected_sig = tmp_set(tmp_exc(1),:);
                
            end
            new_path_set{path_num} = selected_sig;
            new_path_set;
        end
        %power spectrum entropy
        bck_pse = power_spectral_entropy(raw_bck);
        noise_new_ECB_st = new_ECB_factor(raw_bck);
        
        %tennis_local_factor = local_factor_calculate_from_path_sig(sensor,path_set, distance,bck);
        [local_factor_array, fin_bandwidth, fin_sub_bck_bandwidth, original_SNR, SSIM, fin_signal_ECB, sig_pse]...
            = local_factor_calculate_random_fa(scenario, sensor,new_path_set, distance,bck, raw_bck(1:1000));
        %local_factor_array = [local_factor_array, bandwidth]
        local_factor =[];
        local_factor.lf = local_factor_array;
        local_factor.sig_bd =fin_bandwidth;
        local_factor.sig_sub_bck_bd = fin_sub_bck_bandwidth;
        local_factor.SNR = original_SNR;
        local_factor.SSIM = SSIM;
        local_factor.signal_new_ECB = fin_signal_ECB;
        local_factor.signal_pse = sig_pse;
        local_factor.bck_pse = bck_pse;
        local_factor.noise_new_ECB = noise_new_ECB_st';
        
        local_factor.bck_bd =[];
        %local_factor_array = local_factor_calculate_all_path_all_datapoint(sensor,path_set, distance,bck);
        
        if isnan(fin_signal_ECB(1))
            success_flag(sensor) = 1;
        end
        
        re{sensor} = local_factor;
        
    end
    if sum(success_flag) ==0
        for sensor =1:sen_number
            eval(['mul_tennis_factor_s', num2str(sensor),'_',num2str(success_count) '= re{',num2str(sensor),'};'])
            eval(['save(file_name, ''mul_tennis_factor_s', num2str(sensor),'_',num2str(success_count),''',''-append'');'])
            
        end
        success_count = success_count+1;
    end
    if success_count > 200
        break;
    end
    end
end
close(h)