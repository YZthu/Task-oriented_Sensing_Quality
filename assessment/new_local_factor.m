function [trad_lf, sig_bd, sig_sub_bck_bd, bck_bd, SNR, SSIM] = new_local_factor( local_factor )

sensor_fa = local_factor.lf;
sig_bd = local_factor.sig_bd;
sig_sub_bck_bd = local_factor.sig_sub_bck_bd;
bck_bd = local_factor.bck_bd;
if isfield(local_factor,'original_SNR')
    SNR = local_factor.original_SNR; %tennis
else
    SNR = local_factor.SNR; %footstep
end
SSIM = local_factor.SSIM;
% A B R H
local_H = sensor_fa(4);
fft_H = sensor_fa(5);
local_R = sensor_fa(3);

local_A = sensor_fa(1);
local_B = sensor_fa(2);

lo_A = local_A;
lo_B = local_B;

%calculate sensing range
sensing_range = 0;
if local_A > -0.5 | local_B < 3
    sensing_range = 2;
else
    sensing_range = local_B / abs(local_A);
end
if sensing_range > 14
    sensing_range = 14;
end
fin_sr = log(sensing_range-1)/log(13);

%constrain the mean_B and mean_A value in the range of 0 to 1
B_th =[6,20];
A_th = [-2.7,-0.4];

if local_B < B_th(1)
    local_B = B_th(1);
else
    if local_B > B_th(2)
        local_B = B_th(2);
    end
end

if local_A < A_th(1)
    local_A = A_th(1);
else
    if local_A > A_th(2)
        local_A = A_th(2);
    end
end


PAR=polyfit(B_th,[0,1],1);
nor_B = PAR(1)*local_B + PAR(2);
if nor_B< 0
    nor_B =0;
else
    if nor_B > 1;
        nor_B =1;
    end
end

PAR=polyfit(A_th,[0,1],1);
nor_A = PAR(1)*local_A + PAR(2);
if nor_A< 0
    nor_A =0;
else
    if nor_A > 1;
        nor_A =1;
    end
end
trad_lf =[nor_A, nor_B, lo_A, lo_B,local_R, local_H, fft_H];
end