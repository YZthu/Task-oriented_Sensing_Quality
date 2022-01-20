clear all;
close all;
clc;

deployment_name ={'Garage', 'Aisle_rug', 'Bridge',...
    'Hall', 'Aisle', 'Livingroom_rug','Livingroom_base','Garage_k','Outdoor',...
    "Lab_beam", "Aisle_beam"};
%collect the Lab/Carpet/Aisle 
%put the sensor close to the wall
%put the sensor on the road base
%add two sensors with 40dB and 80dB
%update the vibration result for IMWUT

later_pa ='_footstep_SE.mat';
dataset_path ='../footstep_mat';
%use all path to calculate the factor
support_sc = 10:11;
start_time = clock;
for scenario = support_sc
    scenario
    time_interval = etime(clock,start_time)
    start_time = clock;
    file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_pa)];
    load(file_name);

    for sensor=1:6
        %bck = BCK(sensor);
        eval(['raw_bck = Y_S2_', num2str(sensor),'_bck;'])
        eval(['raw_path_vs = Y_S2_', num2str(sensor),'_raw_path_vs;'])
        eval(['path_sig_loc = Y_S2_', num2str(sensor),'_path_log;'])
        eval(['foot_path_set = Y_S2_', num2str(sensor),'_ftst;'])
        raw_bck_sig = raw_bck;
        bck = mean(raw_bck_sig.^2);
        if sensor ==1 | sensor == 4
            distance = [2,2,2];
        else
            distance = [2,2,2];
        end
        
        ene_th =0.95:-0.05:0.1;
        total_nu = size(ene_th,2);
        bck_bd =zeros(1, total_nu);
        
        for counn=1:total_nu 
            tmp_bd = find_contreat_band(raw_bck_sig(1:1000),ene_th(counn));
            bck_bd(counn) = tmp_bd;
        end
        
        path_set ={};
        path_vs ={};
        sig_loc ={};
        for kk=1:size(foot_path_set,2)
            tmp_set = foot_path_set{kk};
            tmp_raw_vs = raw_path_vs{kk};
            tmp_sig_loc = path_sig_loc{kk};
            path_set(kk) = {tmp_set};
            path_vs(kk) = {tmp_raw_vs};
            sig_loc(kk) = {tmp_sig_loc};
        end
        %power spectrum entropy
        bck_pse = power_spectral_entropy(raw_bck_sig);
        
        [local_factor_array, fin_bandwidth, fin_sub_bck_bandwidth, SNR, SSIM, fin_signal_ECB, mean_H,sig_pse] = footstep_local_factor_calculate_all_path(sensor, path_set, distance,bck, raw_bck_sig, path_vs, sig_loc);
        
        local_factor.lf = local_factor_array;
        local_factor.sig_bd =fin_bandwidth;
        local_factor.sig_sub_bck_bd = fin_sub_bck_bandwidth;
        local_factor.bck_bd =bck_bd;
        local_factor.SNR = SNR;
        local_factor.SSIM = SSIM;  
        local_factor.signal_new_ECB = fin_signal_ECB;
        local_factor.signal_pse = sig_pse;
        local_factor.bck_pse = bck_pse;
        
        local_factor.mean_H = 0;%mean_H;
        eval(['footstep_local_factor_s', num2str(sensor), '=local_factor;']);
    end
    later_part = '_footstep_fix_distance_factor.mat';
    file_name = ['./',char(deployment_name(scenario)), char(later_part)]
    save(file_name,'footstep_local_factor_s1','footstep_local_factor_s2','footstep_local_factor_s3','footstep_local_factor_s4');
    
end
