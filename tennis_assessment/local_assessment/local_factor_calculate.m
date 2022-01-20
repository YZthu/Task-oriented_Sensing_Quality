clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

later_part ="_tennis_path_sig_SE.mat";
dataset_path ='../tennis_path_sig';

background_bandwidth = [];
sc_p =1:11;
h=waitbar(0,'please wait');
for scenario =  sc_p
    file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_part)];
    load(file_name);
    sensor_bandwidth =[];
    sen_number = 4;
    if scenario > 9
        sen_number =6;
    end
    for sensor = 1:sen_number
        waitbar(((scenario-2)*4+sensor) / 40, h, ['sc ', num2str(scenario),...
           ' sen ', num2str(sensor)]);
        eval(['path_set = path_sig_set', num2str(sensor), ';' ])
        eval(['bck = bck', num2str(sensor), ';']);
        eval(['raw_bck = raw_bck', num2str(sensor), ';']);
        
        bandwidth = find_contreat_band(raw_bck(1:1000), 0.9);
        sensor_bandwidth(sensor) = bandwidth;
        
        ene_th =0.95:-0.05:0.1;
        total_nu = size(ene_th,2);
        bck_bd =zeros(1, total_nu);
        %{
        for counn=1:total_nu 
            tmp_bd = find_contreat_band(raw_bck(1:1000),ene_th(counn));
            bck_bd(counn) = tmp_bd;
        end
        %}
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
        
        %power spectrum entropy
        bck_pse = power_spectral_entropy(raw_bck);
        noise_new_ECB_st = new_ECB_factor(raw_bck);
        
        tennis_local_factor = local_factor_calculate_from_path_sig(scenario, sensor,path_set, distance,bck);
        [local_factor_array, fin_bandwidth, fin_sub_bck_bandwidth, original_SNR, SSIM, fin_signal_ECB, sig_pse] = local_factor_calculate_all_path(scenario,sensor,path_set, distance,bck, raw_bck(1:1000));
        %local_factor_array = [local_factor_array, bandwidth]
        local_factor=[];
        local_factor.lf = local_factor_array;
        local_factor.sig_bd =fin_bandwidth;
        local_factor.sig_sub_bck_bd = fin_sub_bck_bandwidth;
        local_factor.bck_bd =bck_bd;
        local_factor.SNR = original_SNR;
        local_factor.SSIM = SSIM;
        local_factor.signal_pse = sig_pse;
        local_factor.bck_pse = bck_pse;
        local_factor.noise_new_ECB = noise_new_ECB_st';
        
        local_factor.signal_new_ECB = fin_signal_ECB;
        %local_factor_array = local_factor_calculate_all_path_all_datapoint(sensor,path_set, distance,bck);
        eval(['tennis_local_factor_s', num2str(sensor), '= tennis_local_factor;']);
        eval(['new_tennis_local_factor_s', num2str(sensor), '= local_factor;'])
    end
    later_p ="_tennis_local_factor.mat";
    file_name = [char(deployment_name(scenario)), char(later_p)]
    
    save(file_name,'tennis_local_factor_s1','tennis_local_factor_s2','tennis_local_factor_s3',...
        'tennis_local_factor_s4','new_tennis_local_factor_s1','new_tennis_local_factor_s2',...
        'new_tennis_local_factor_s3','new_tennis_local_factor_s4', 'raw_bck1', 'raw_bck2', 'raw_bck3', 'raw_bck4');
    if scenario > 9
        save(file_name,'tennis_local_factor_s5','tennis_local_factor_s6',...
        'new_tennis_local_factor_s5','new_tennis_local_factor_s6', 'raw_bck5', 'raw_bck6','-append');
    end
    
    %background_bandwidth = [background_bandwidth, sensor_bandwidth'];
end