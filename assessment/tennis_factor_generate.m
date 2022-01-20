function [ABRH_Met, bandwidth_Met, SNR, fin_SSIM, new_ECB_fa, bck_pse, signal_pse,noise_new_ECB_fa,full_SNR] = tennis_factor_generate(add_path, support_sc)


deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
%support_sc = [1,2,3,6,7,8,9,10,11,12];
dataset_path =[add_path,'../tennis_assessment/local_assessment/'];
%later_part ="_tennis_local_factor.mat";
later_part ="_tennis_local_factor_15.mat";

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
noise_new_ECB_fa = [];
bck_pse =[];
signal_pse=[];
full_SNR ={};
count =0;
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
        eval(['current_l_f = new_tennis_local_factor_s', num2str(sensor_num), ';'])
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
        %total_sig_bd =[total_sig_bd, sig_bd];
        %total_sig_bck_bd = [total_sig_bck_bd, sig_sub_bck_bd];
        %total_bck_bd = [total_bck_bd, bck_bd'];
        
        if scenario > 9
            if sensor_num ==1 |sensor_num ==2 | sensor_num ==5 |sensor_num ==6
                cent_loc=5;
            end
            if sensor_num ==3 | sensor_num ==4
                cent_loc =6;
            end
        else
            if sensor_num ==1 |sensor_num ==2 | sensor_num ==5 |sensor_num ==6
                cent_loc=3;
            end
            if sensor_num ==3 | sensor_num ==4
                cent_loc =6;
            end
        end
        
        new_factor_ECB = current_l_f.signal_new_ECB;
        new_ECB_fa =[new_ECB_fa; new_factor_ECB'];
        %noise ECB
        noise_new_ecb = current_l_f.noise_new_ECB;
        bb= isnan(noise_new_ecb);
        if sum(bb)>0
            loc = find(bb==1);
            if loc ==1
                noise_new_ecb(1) = 2*noise_new_ecb(2)-noise_new_ecb(3);
            end
            if loc ==2
                noise_new_ecb(2) = (noise_new_ecb(1)+noise_new_ecb(3))/2;
            end
            if loc ==3
                noise_new_ecb(1) = 2*noise_new_ecb(2)-noise_new_ecb(1);
            end
            e='e';
        end
        noise_new_ECB_fa = [noise_new_ECB_fa; noise_new_ecb'];
        
        bck_pse =[bck_pse, current_l_f.bck_pse];
        signal_pse=[signal_pse, current_l_f.signal_pse];
        
        %local_bandwidth = sig_bd';
        bck_bandwidth = bck_bd;
        sele =1:18;
        bck_bandwidth = bck_bandwidth(sele);
        sig_sub_bck = sig_sub_bck_bd(sele)';
        sig_bandwidth = sig_bd(sele)';
        

            selected_SNR = [
            cur_SNR(cent_loc),nanmean([cur_SNR(cent_loc-2),cur_SNR(cent_loc-1)]),nanmean([cur_SNR(cent_loc+1),cur_SNR(cent_loc+2)]),...
            cur_SNR(cent_loc+8),nanmean([cur_SNR(cent_loc-2+8),cur_SNR(cent_loc-1+8)]),nanmean([cur_SNR(cent_loc+1+8),cur_SNR(cent_loc+2+8)]),...
            cur_SNR(cent_loc+16),nanmean([cur_SNR(cent_loc-2+16),cur_SNR(cent_loc-1+16)]),nanmean([cur_SNR(cent_loc+1+16),cur_SNR(cent_loc+2+16)])];

        tmp_SNR_map =[cur_SNR(cent_loc-2:cent_loc+2); cur_SNR(cent_loc-2+8:cent_loc+2+8); cur_SNR(cent_loc-2+16:cent_loc+2+16);];
        count = count +1;
        full_SNR(count) ={tmp_SNR_map};
        %SNR = [SNR; selected_SNR];
        %fin_SSIM = [fin_SSIM; SSIM];
        each_path_SNR = reshape(selected_SNR, [], 3);
        mean_SNR = nanmean(each_path_SNR,2)';
        
        if length(SSIM)< 6
            for ii=1:6-length(SSIM)
                SSIM = [SSIM, mean(SSIM)];
            end
        end
        if length(SSIM)~= 6
            e='e';
        end
        each_path_SSIM = reshape(SSIM, [], 3);
        mean_SSIM = nanmean(each_path_SSIM,2)';
        SNR= [SNR; mean_SNR];
        fin_SSIM = [fin_SSIM; mean_SSIM];
        
        
        local_bandwidth = [sig_bandwidth, sig_sub_bck, bck_bandwidth];
        ABRH_factor_val=[local_A, local_B, local_R, local_H, fft_H];
        ABRH_Met = [ABRH_Met; ABRH_factor_val];
        bandwidth_Met = [bandwidth_Met; local_bandwidth];
    end

end

end