function [ABRH_Met, bandwidth_Met, SNR, fin_SSIM, new_ECB_fa, bck_pse, signal_pse,noise_new_ECB_fa] = footstep_factor_generate(add_path, support_sc)


deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

%support_sc = [1,2,3,6,7,8,9,10,11,12];
dataset_path =[add_path,'../footstep_assessment/local_factor_val/'];
%later_part ="_footstep_local_factor.mat";
later_part ="_footstep_fix_distance_factor.mat";

bck_bandwidth =[];
total_sig_bd =[];
total_sig_bck_bd =[];
total_bck_bd =[];
%support_sc = [1,2,3,6,7,8,9,10,11,12];

ABRH_Met =[];
bandwidth_Met =[];
SNR = [];
fin_SSIM =[];
new_ECB_fa =[];
noise_new_ECB_fa =[];
mean_H =[];
bck_pse =[];
signal_pse=[];

for scenario =support_sc
    
file_name = [dataset_path, char(deployment_name(scenario)), char(later_part)];
load(file_name)

%local
% eA eB iA iB H
%super_M = [tennis_s1; tennis_s2; tennis_s3; tennis_s4];
sen_number = 4;
if scenario >9
    sen_number =6;
end

    for sensor_num=1:sen_number
         %[fin_A,fin_B, fin_R, fin_H];
        eval(['current_l_f = footstep_local_factor_s', num2str(sensor_num), ';'])
        [trad_lf, sig_bd,sig_sub_bck_bd, bck_bd, cur_SNR, SSIM] = new_local_factor(current_l_f);
        nor_A = trad_lf(1);
        nor_B = trad_lf(2);
        local_A = trad_lf(3);
        local_B = trad_lf(4);
        local_R = trad_lf(5);
        local_H = trad_lf(6);
        fft_H = trad_lf(7);
        %sig_bd 90,85... 10
        %bck_bd 90,85... 10
        total_sig_bd =[total_sig_bd, sig_bd];
        total_sig_bck_bd = [total_sig_bck_bd, sig_sub_bck_bd];
        total_bck_bd = [total_bck_bd, bck_bd'];
        bck_pse =[bck_pse, current_l_f.bck_pse];
        signal_pse=[signal_pse, current_l_f.signal_pse];

        new_factor_ECB = current_l_f.signal_new_ECB;
        %noise ECB
        noise_new_ecb = current_l_f.noise_new_ECB;
        noise_new_ECB_fa = [noise_new_ECB_fa; noise_new_ecb];
        
        tmp_mean_H = current_l_f.mean_H;
        %local_bandwidth = sig_bd';
        bck_bandwidth = bck_bd;
        sele =1:3;
        bck_bandwidth = bck_bandwidth(sele);
        sig_sub_bck = sig_sub_bck_bd(sele)';
        sig_bandwidth = sig_bd(sele)';
        
        cur_SNR;
        size(cur_SNR);
        
        lane1_snr =nanmean(cur_SNR(1:6,:));
        lane2_snr =nanmean(cur_SNR(7:12,:));
        if 12 <size(cur_SNR,1) 
            lane3_snr = nanmean(cur_SNR(13:end,:));
        else
            lane3_snr =NaN(1,3);
        end
        
        %selected_SNR =[lane1_snr, lane2_snr, lane3_snr];
        selected_SNR = nanmean(cur_SNR, 1);
        SNR = [SNR; selected_SNR];
        
        lane1_ssim = nanmean(SSIM(1:6,:));
        lane2_ssim = nanmean(SSIM(7:12,:));
        if 12< size(SSIM,1)< 18
            lane3_ssim = nanmean(SSIM(13:end,:));
        else
            lane3_ssim = NaN(1,3);
        end
        
        if isnan(lane3_snr(1)) | isnan(lane3_ssim(1))
            err='e';
        end
        
        %selected_SSIM =[lane1_ssim, lane2_ssim, lane3_ssim];
        selected_SSIM = nanmean(SSIM,1);
        fin_SSIM = [fin_SSIM; selected_SSIM];
        
        local_bandwidth = [sig_bandwidth, sig_sub_bck, bck_bandwidth];
        ABRH_factor_val=[local_A, local_B, local_R, local_H, fft_H];
        ABRH_Met = [ABRH_Met; ABRH_factor_val];
        bandwidth_Met = [bandwidth_Met; local_bandwidth];
        new_ECB_fa =[new_ECB_fa; new_factor_ECB'];
        mean_H =[mean_H; tmp_mean_H];
    end
    
end

end