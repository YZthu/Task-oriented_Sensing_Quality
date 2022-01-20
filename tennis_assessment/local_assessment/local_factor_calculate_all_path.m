function [local_factor_array, fin_bandwidth, fin_bck_bandwidth, original_SNR, fin_SSIM, fin_signal_ECB,fin_signal_pse] = local_factor_calculate_all_path(scenario, sensor, path_set, distance_set,bck, raw_bck)

e_A = [];
e_B = [];
i_A = [];
i_B = [];
R_e = [];
R_i = [];
H = [];
FFT_H =[];
local_factor_array = NaN;
fin_bandwidth = NaN;
fin_bck_bandwidth = NaN;
original_SNR = NaN; 
fin_SSIM = NaN;
fin_signal_ECB = NaN;
fin_signal_pse =NaN;

%for path_num =1:size(path_set,2)
all_SNR=[];
all_bandwidth =NaN(18,size(path_set,2));
all_bck_bandwidth =NaN(18,size(path_set,2));
all_signal_ECB_bd =NaN(4,size(path_set,2));
for path_num =1:size(path_set,2)
    tmp_sig_set = cell2mat(path_set(path_num));
    SNR =[];
    raw_bandwidth = [];
    bck_bandwidth = [];
    new_signal_ECB_bd =[];
    signal_pse =[];
    for ind = 1:size(tmp_sig_set,1)
        
        tmp_sig = tmp_sig_set(ind,:);
        ene_th =0.95:-0.05:0.1;
        total_nu = size(ene_th,2);
        raw_bd=NaN(1, total_nu);
        bd_bck =NaN(1, total_nu);
        %{
        for counn=1:total_nu 
            tmp_bd = find_contreat_band(tmp_sig,ene_th(counn));
            tmp_bd_bck = find_contreat_band_bck(tmp_sig, raw_bck,ene_th(counn));
            if length(tmp_bd)>0
                raw_bd(counn) = tmp_bd;
            end
            if length(tmp_bd_bck)>0
                bd_bck(counn) = tmp_bd_bck; 
            end

        end
        %}
                    %new ECB
            new_ECB_st = new_ECB_factor(tmp_sig);
            tmp_pse = power_spectral_entropy(tmp_sig);
            
        tmp_bandwidth = raw_bd;
        tmp_bandwidth_bck = bd_bck';
        tmp_bandwidth = tmp_bandwidth';
        if isnan(tmp_bandwidth(1))
            s='ss';
        end
        tmp_snr = 10*log(mean(tmp_sig.^2)/bck)/log(10);
        %if tmp_snr < 3
            %tmp_snr = NaN;
        %end
        SNR = [SNR, tmp_snr];
        if size(tmp_bandwidth,1) ~= 18
            tmp_bandwidth;
        end
        raw_bandwidth = [raw_bandwidth, tmp_bandwidth];
        bck_bandwidth = [bck_bandwidth, tmp_bandwidth_bck];
        new_signal_ECB_bd =[new_signal_ECB_bd, new_ECB_st'];
        signal_pse = [signal_pse, tmp_pse];
    end
    rank_SNR = sort(SNR);
    if length(SNR)> 4
        new_SNR = SNR(2:end-1);
    else
        new_SNR = SNR;
    end
    all_SNR(path_num) =  nanmean(new_SNR);
    if size(raw_bandwidth,1) ==0
        continue;
    else
        all_bandwidth(:,path_num) = mean(raw_bandwidth,2,'omitnan');
        all_bck_bandwidth(:, path_num) = mean(bck_bandwidth, 2,'omitnan');
        all_signal_ECB_bd(:,path_num) = mean(new_signal_ECB_bd, 2, 'omitnan');
        all_signal_pse(:, path_num) = mean(signal_pse, 'omitnan');
    end
end
plot_bandwidth = all_bandwidth(1,:);

%{
figure
plot(plot_band)
title([num2str(sensor), ' bandwidth', ])
legend('1', '2', '3')
%}

    switch sensor
        case 1
            loc = 3;
        case 2
            loc = 3;
        case 3
            loc = 6;
        case 4
            loc = 6;
    end
    if scenario > 9
        if sensor ==1 |sensor ==2 | sensor ==5 |sensor ==6
            loc=5;
        end
        if sensor ==3 | sensor ==4
            loc =6;
        end
    end
    
        all_bandwidth = all_bandwidth(:,[loc,loc+8,loc+16]);
        all_bck_bandwidth = all_bck_bandwidth(:,[loc,loc+8,loc+16]);
        all_signal_ECB_bd = all_signal_ECB_bd(:,[loc,loc+8,loc+16]);
        all_signal_pse = all_signal_pse(:,[loc,loc+8,loc+16]);


%{
figure
plot(all_SNR)
title(num2str(sensor))
%}
%%
original_SNR = all_SNR;
tmp_SNR=reshape(all_SNR, size(all_SNR,2)/3,3)';


%%distance_set
total_distance = zeros(3,8);
fin_SSIM =[];

for path_num=1:3
    switch sensor
        case 1
            loc = 3;
        case 2
            loc = 3;
        case 3
            loc = 6;
        case 4
            loc = 6;
    end
    if scenario > 9
        if sensor ==1 |sensor ==2 | sensor ==5 |sensor ==6
            loc=5;
        end
        if sensor ==3 | sensor ==4
            loc =6;
        end
    end
      
    distance = distance_set(path_num);  % different have different config
    for part1=1:8
        tmp_dist = sqrt(distance^2 + (2*(loc-part1))^2);
        total_distance(path_num, part1)= tmp_dist;
    end
    
     
    %H 
    coun =  3;
    tmp_H =[];
    tmp_ffth =[];
    SSIM =NaN(1, coun-1);
    for sample =2:coun
        sig1_loc_set = cell2mat(path_set((path_num-1)*size(tmp_SNR,2) + loc - (sample-1)));
        sig2_loc_set = cell2mat(path_set((path_num-1)*size(tmp_SNR,2) + loc + (sample-1)));
        current_ssim =[];
        if size(sig2_loc_set,2)< 10 | size(sig1_loc_set,2)< 10
            continue;
        end
        for sig1_number=1:size(sig1_loc_set,1)
            sig1 = sig1_loc_set(sig1_number,:);
            for sig2_num =1:size(sig2_loc_set,1)
                sig2 = sig2_loc_set(sig2_num,:);
                
                tmp_ssim = SSIM_index(sig1, sig2);
                sig11 = sig1./sqrt(sum(sig1.^2));
                sig22 = sig2./sqrt(sum(sig2.^2));
                
        fft1 = fft(sig1, 6500);
        tmp_fft = abs(fft1);
        fft2 = fft(sig2, 6500);
        tmp_fft2 = abs(fft2);
        fft_up=200;
        
        ff1 = tmp_fft(1:fft_up);
        ff2 = tmp_fft2(1:fft_up);
        ff1 = ff1./sqrt(sum(ff1.^2));
        ff2 = ff2./sqrt(sum(ff2.^2));                
                
                current_ssim = [current_ssim, tmp_ssim];
                h = max(xcorr(sig11, sig22));
                tmp_H = [tmp_H, h];
                fft_h = max(xcorr(ff1, ff2));
                tmp_ffth = [tmp_ffth, fft_h];
            end
        end
        SSIM(sample-1) =  mean(current_ssim);
    end
    H = [H, max(tmp_H)];
    FFT_H =[FFT_H, max(tmp_ffth)];
    fin_SSIM = [fin_SSIM, SSIM];
end
    
        new_snr = tmp_SNR;
        new_dist = total_distance;
   
    
    fin_dist = reshape(new_dist', 1,24);
    fin_snr = reshape(new_snr', 1,24);
    
    %delete 
    kk =1
    while 1
        if isnan(fin_snr(kk))
            fin_snr(kk) =[];
            fin_dist(kk) =[];
            kk=1;
        else
            kk = kk+1;
        end
        if kk> size(fin_snr,2)
            break;
        end
    end
    % if snr < 3 delete
    for del_c =size(fin_snr,2):-1:1
        if fin_snr(del_c) < 3
            %fin_snr(del_c) =[];
            %fin_dist(del_c) =[];
        end
    end
    
    %fit
    %ab = polyfit(fin_dist, fin_snr+ log(fin_dist/2),1);
    tmp_dist = fin_dist;
    tmp_snr = fin_snr + 20*0.5*log(fin_dist);
    full_snr = tmp_snr;
    full_dist = tmp_dist;
    del_dist =[];
    del_snr =[];
    while 1
        [ab, S] = polyfit(tmp_dist, tmp_snr,1 );
        
        if size(tmp_snr,2)< 2
            local_factor_array=[0, 0, 0, 0,0];
            return
        end
        
        tmp_distance = [];
        for kk=1:size(tmp_dist,2)
            tmp_tmp_dist = abs(ab(1)*tmp_dist(kk)+ ab(2) -tmp_snr(kk))/sqrt(1 + ab(1)^2);
            tmp_distance = [tmp_distance, tmp_tmp_dist];
        end
        sigma = std(tmp_distance);
        miu = mean(tmp_distance);
        %delete 2 sigma 
        kk =1
        while 1 
            if abs(tmp_distance(kk) ) > 2*sigma
                del_dist = [del_dist, tmp_dist(kk)];
                del_snr = [del_snr, tmp_snr(kk)];
                tmp_snr(kk) = [];
                tmp_dist(kk) = [];
                tmp_distance(kk) = [];
            else
                kk = kk+1;
            end
            if kk > size(tmp_distance,2)
                break
            end
        end
        
        break
    end
    if size(tmp_dist,2) < 3
        local_factor_array=[0, 0, 0, 0,0];
        fin_bandwidth = NaN;
        fin_bck_bandwidth = NaN;
        fin_signal_ECB = NaN;
        return
    end

    [y,delta] = polyval(ab,tmp_dist, S);
    
    %y = ab(1)*tmp_dist + ab(2);
    
    % two sigma bound 
    old_distance = tmp_distance;
                
        tmp_distance = [];
        for kk=1:size(tmp_dist,2)
            tmp_tmp_dist = abs(ab(1)*tmp_dist(kk)+ ab(2) -tmp_snr(kk))/sqrt(1 + ab(1)^2);
            tmp_distance = [tmp_distance, tmp_tmp_dist];
        end
        %sigma = std(tmp_distance);
            
    two_sigma_y = sqrt(ab(1)^2+1)*2*sigma;
    
    low_band_y = ab(1)*tmp_dist + ab(2) - two_sigma_y; %- log(tmp_dist)/2;
    up_band_y = ab(1)*tmp_dist + ab(2) + two_sigma_y; %- log(tmp_dist)/2;
    
    bound_y = [low_band_y', up_band_y'];
        
    repair_y = y - log(tmp_dist)/2;
    repair_snr = tmp_snr - log(tmp_dist)/2;
        repair_del_snr =del_snr - log(del_dist)/2;
        
        
        %{
    fi = figure
    set(gca,'Fontsize',10);
    plot(tmp_dist, tmp_snr , 'o');
    hold on
    plot(del_dist, del_snr, '*');
    hold on
            plot(tmp_dist, y , 'r', 'linewidth',2)
    hold on
    [ab, S] = polyfit(tmp_dist, tmp_snr,1 );
    [y,delta] = polyval(ab,tmp_dist, S);

    plot(tmp_dist, y, 'b', 'linewidth',2);
    hold on
    [~,st] = min(tmp_dist);
    [~,sp] = max(tmp_dist);
    plot(tmp_dist([st,sp]),low_band_y([st,sp]), 'k--', 'linewidth',2);
    hold on
    plot(tmp_dist([st,sp]),up_band_y([st,sp]), 'k--', 'linewidth',2);

    
    xlabel('Distance (ft)');
    ylabel('SNR + log(d)/2');
    legend('Data Points', 'Outlier Points',' Initial Model', 'Rectified Model', '2 Sigma Boundry')
    ylim([0 30])
       
    figue_name =['../../assessment/full_set_relative_rank_assessment/figures/decay_model.jpg'];
    saveas(fi, figue_name);
    figue_name =['../../assessment/full_set_relative_rank_assessment/figures/decay_model.fig'];
    saveas(fi, figue_name);
    figue_name =['../../assessment/full_set_relative_rank_assessment/figures/decay_model.eps'];
    saveas(fi, figue_name, 'epsc');
    %}
        
    [ab, S] = polyfit(tmp_dist, tmp_snr,1 );
    [y,delta] = polyval(ab,tmp_dist, S);
    tpc = corrcoef(y, tmp_snr);% check
    R = abs(tpc(2,1));

    %figure
    %{
    figure
    plot(tmp_dist, tmp_snr, 'o')
    hold on
    
    plot(tmp_dist, y, '-')
    plot(tmp_dist,y+2*delta,'m--',tmp_dist,y-2*delta,'m--')
    hold on
    plot(del_dist, del_snr, '*');
    title(['A ', num2str(ab(1)), ' B ', num2str(ab(2)), ' R ', num2str(R), ' H ', num2str(max(H))])
    %}
    
fin_A = ab(1);
fin_B = ab(2);
fin_R = R; % square root of coefficient of determination
fin_H = max(H);
fin_fftH = max(FFT_H);
fin_bandwidth = nanmean(all_bandwidth,2);
fin_bck_bandwidth = nanmean(all_bck_bandwidth,2);
fin_signal_ECB = nanmean(all_signal_ECB_bd,2);
fin_signal_pse = nanmean(all_signal_pse);
local_factor_array =[fin_A, fin_B, fin_R, fin_H, fin_fftH];
end