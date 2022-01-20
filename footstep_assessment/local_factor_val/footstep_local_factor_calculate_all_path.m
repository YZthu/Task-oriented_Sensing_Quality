function [local_factor_array, fin_bandwidth, fin_bck_bandwidth,SNR_factor,SSIM_factor, fin_signal_ECB_bd,mean_H,fin_signal_pse] = footstep_local_factor_calculate_all_path(scenario,sensor, path_set, distance_set,bck, raw_bck_sig, path_vs, path_sig_loc)

%%distance_set
fin_dist =[];
fin_snr =[];
H =[];
FFT_H =[];
mean_H =[];
fin_bandwidth = NaN(3, 1);
fin_bck_bandwidth = NaN(3, 1);
fin_signal_ECB_bd = NaN(3,1);
fin_signal_pse = NaN;
all_bandwidth = NaN(3, size(path_set,2));
all_sub_bck_bandwidth = NaN(3, size(path_set,2));
all_signal_ECB_bd = NaN(4, size(path_set,2));
all_signal_pse = NaN(1, size(path_set,2));

path_selected_snr_dist = {};
path_R = [];
path_count =0;
all_path_snr =NaN(18,3);
fin_SSIM =NaN(18,2);
for path_num=1:size(path_set,2)
    switch sensor
        case 1
            it_loc = 3;
        case 2
            it_loc = 3;
            
        case 3
            it_loc = 6;
        case 4
            it_loc = 6;
    end
    if scenario ==10
        switch sensor
            case 1
                it_loc = 5;
            case 2
                it_loc = 5;

            case 3
                it_loc = 6;
            case 4
                it_loc = 6;
            case 5
                it_loc = 6;
            case 6
                it_loc =6;
        end
    end
    if scenario ==11
        switch sensor
            case 1
                it_loc = 5;
            case 2
                it_loc = 5;

            case 3
                it_loc = 6;
            case 4
                it_loc = 6;
            case 5
                it_loc = 6;
            case 6
                it_loc =6;
        end
    end
    
    if mod(path_num,2) == 0
        loc = 9 - it_loc;
    else
        loc = it_loc;
    end
    
    tmp_sig_set = cell2mat(path_set(path_num));
    SNR =[];
    raw_bandwidth = [];
    bck_bandwidth = [];
    signal_ECB_bd =[];
    signal_pse =[];
    
    raw_vs = path_vs{path_num};
    all_sig =[];
    interval = round((size(raw_vs,2) - 1000*size(tmp_sig_set,1))/size(tmp_sig_set,1));
    for ind = 1:size(tmp_sig_set,1)
        tmp_sig = tmp_sig_set(ind,:);
        all_sig = [all_sig, tmp_sig];
        all_sig = [all_sig, zeros(1,interval)];
        tmp_snr = 10*log(mean(tmp_sig.^2)/bck)/log(10);

        
        %energy bandwidth 
        ene_th =[0.9,0.75,0.5];
        total_nu = size(ene_th,2);
        raw_bd=NaN(1, total_nu);
        bd_bck =NaN(1, total_nu);
        new_ECB_st = NaN(1, 4);
        tmp_pse =NaN;
        if ~isnan(tmp_sig(1))
            %{
            for counn=1:total_nu 
                tmp_bd = find_contreat_band(tmp_sig,ene_th(counn));
                tmp_bd_bck = find_contreat_band_bck(tmp_sig, raw_bck_sig,ene_th(counn));
                if length(tmp_bd)~=1
                    e='e';
                end
                raw_bd(counn) = tmp_bd;
                bd_bck(counn) = tmp_bd_bck;
            end
            %}
            new_ECB_st = new_ECB_factor(tmp_sig);
            tmp_pse = power_spectral_entropy(tmp_sig);
        end
        
        tmp_bandwidth = raw_bd';
        tmp_bandwidth_bck = bd_bck';
        tmp_signal_ECB = new_ECB_st';
        tmp_sig_pse = tmp_pse;
        
        if tmp_snr < 0
            tmp_snr = NaN;
            raw_bd=NaN(1, total_nu)';
            bd_bck =NaN(1, total_nu)';
        end
        SNR = [SNR, tmp_snr];
        
        raw_bandwidth = [raw_bandwidth, tmp_bandwidth];
        bck_bandwidth = [bck_bandwidth, tmp_bandwidth_bck];
        signal_ECB_bd = [signal_ECB_bd, tmp_signal_ECB];
        signal_pse = [signal_pse, tmp_sig_pse];
    end
    %{
    figure
    raw_vs = path_vs{path_num};
    plot(raw_vs);
    sig_loc = path_sig_loc{path_num};
    sig_mark = ones(1,length(sig_loc))*0.7*max(raw_vs);
    hold on
    plot(sig_loc, sig_mark, '*')
    hold on
    plot(all_sig);
    
    title(['sensor ', num2str(sensor), '  path number: ', num2str(path_num)]) 
    %}
    
    %delete the fraway 3 datapoint.
    %{
    if it_loc ==3
        SNR(end) =NaN;
    else
        SNR(1) =NaN;
    end
    %}

    %{
    figure
    plot(SNR)
    title([num2str(sensor),'  ', num2str(path_num), 'loc =', num2str(loc)]);
     %}
    
    % peak detection
    [val, new_loc] = max(SNR);
    if abs(new_loc- loc) < 4
        if new_loc >1 & new_loc < size(SNR,2)
            loc = new_loc;
        else
            err='new loc on edge';
            continue;
        end
    else
        err='new loc too far';
        continue;
    end
    
    % distance calculate
    total_distance = [];
    distance = distance_set(floor((path_num-1)/6)+1);  % different have different config
    for part1=1:size(SNR,2)
        tmp_dist = sqrt(distance^2 + (2*(loc-part1))^2);
        total_distance(part1)= tmp_dist;
    end
    
    %extra part delete
    if new_loc < length(SNR)/2
        if length(SNR)>new_loc + 5
            SNR(new_loc+6:end)=[];
            total_distance(new_loc+6:end) = [];
            raw_bandwidth(:, new_loc+6:end) =[];
            bck_bandwidth(:, new_loc+6:end) =[];
            signal_ECB_bd(:, new_loc+6:end) =[];
            signal_pse(:, new_loc+6:end) =[];
        end
        if new_loc > 3
            SNR(1:new_loc-3) =[];
            total_distance(1:new_loc-3) = [];
            raw_bandwidth(:, 1:new_loc-3) =[];
            bck_bandwidth(:, 1:new_loc-3) =[];
            signal_ECB_bd(:, 1:new_loc-3) =[];
            signal_pse(:, 1:new_loc-3) =[];
        end
    else
        if length(SNR)>new_loc + 2
            SNR(new_loc+3:end)=[];
            total_distance(new_loc+3:end) = [];
            raw_bandwidth(:, new_loc+3:end) =[];
            bck_bandwidth(:, new_loc+3:end) =[];
            signal_ECB_bd(:, new_loc+3:end) =[];
            signal_pse(:, new_loc+3:end) =[];
        end
        if new_loc > 6
            SNR(1:new_loc-6) =[];
            total_distance(1:new_loc-6) = [];
            raw_bandwidth(:, 1:new_loc-6) =[];
            bck_bandwidth(:, 1:new_loc-6) =[];
            signal_ECB_bd(:, 1:new_loc-6) =[];
            signal_pse(:, 1:new_loc-6) =[];
        end
    end
    [val, new_loc] = max(SNR);
    
    %SNR factor calculate
        left_snr =NaN;
        right_snr = NaN;
        if new_loc > 4
            new_snr= flip(SNR);
        else
            new_snr = SNR;
        end
        [~, curr_peak] = max(new_snr);
        count = 0;
        right_stop = min([curr_peak+2, length(new_snr)]);
        right_snr = nanmean(new_snr(curr_peak+1:right_stop));
        left_stop = max([curr_peak-2,1]);
        left_snr = nanmean(new_snr(left_stop:curr_peak-1));
        tmp_path_SNR =[new_snr(curr_peak),left_snr, right_snr];
        all_path_snr(path_num, :) = tmp_path_SNR;
    
    
    %bandwidth record
    all_bandwidth(:, path_num) = raw_bandwidth(:, new_loc);
    all_sub_bck_bandwidth(:,path_num) = bck_bandwidth(:, new_loc);
    all_signal_ECB_bd(:, path_num) = signal_ECB_bd(:, new_loc);
    all_signal_pse(:, path_num) = signal_pse(:, new_loc);
    %{
    figure
    plot(SNR)
    title('new SNR');
    %}
    for kk=length(SNR):-1:1
        if isnan(SNR(kk))
            SNR(kk)=[];
            total_distance(kk)=[];
        end
    end
    if length(SNR)< 3
        continue;
    end
    
    fit_snr = SNR + log(total_distance/2);
    [p,S,mu] = polyfit(total_distance, fit_snr,1);
    y1 = polyval(p,total_distance);
        
    tpc = corrcoef(y1, fit_snr);
    tmp_R = abs(tpc(2,1));
    
    %{
    hold on
    plot(SNR);
    title(num2str(tmp_R))
    figure
    plot(total_distance, SNR, 'o');
    %}
    path_count = path_count +1;
    tmp_snr_dist = [total_distance; SNR];
    path_selected_snr_dist(path_count) = {tmp_snr_dist};
    path_R(path_count) = tmp_R;
 

    %H 
    coun =  min(loc-1, size(tmp_sig_set,1)-loc);
    tmp_H =[];
    tmp_ffth =[];
    tmp_SSIM =NaN(1,2);
    
    for sample =1:coun
        sig1 = tmp_sig_set(loc - sample,:);
        sig2 = tmp_sig_set(loc + sample,:);
        [ssim] = SSIM_index(sig1, sig2);
        if sample < 3
            tmp_SSIM(sample) = ssim;
        end
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
        
        h = max(xcorr(sig11, sig22));
        fft_h = max(xcorr(ff1, ff2));
        tmp_H = [tmp_H, h];
        tmp_ffth = [tmp_ffth, fft_h];

    end
    

    H = [H, max(tmp_H)];
    FFT_H =[FFT_H, max(tmp_ffth)];

    fin_SSIM(path_num, :) = tmp_SSIM;

end


[R_rank_v, loc] = sort(path_R);
R_select = 0.4; % top 40%
percent_index = floor(length(R_rank_v)*(1-R_select))+1;
R_th = R_rank_v(percent_index);
for vilid_index=1:path_count
    current_R = path_R(vilid_index);
    curr_snr_dist = path_selected_snr_dist{vilid_index};
    if current_R >= 0.6 | current_R >= R_th
        current_dist = curr_snr_dist(1,:);
        current_snr = curr_snr_dist(2,:); 
        fin_dist =[fin_dist, current_dist];
        fin_snr =[fin_snr, current_snr];
    end

end



    %fit
    %ab = polyfit(fin_dist, fin_snr+ log(fin_dist/2),1);
    tmp_dist = fin_dist;
    tmp_snr = fin_snr + log(fin_dist/2);
    del_dist =[];
    del_snr =[];
    while 1
        ab = polyfit(tmp_dist, tmp_snr,1 );
        
        tmp_distance = [];
        for kk=1:size(tmp_dist,2)
            tmp_tmp_dist = abs(ab(1)*tmp_dist(kk)+ ab(2) -tmp_snr(kk))/sqrt(1 + ab(1)^2);
            tmp_distance = [tmp_distance, tmp_tmp_dist];
        end
        sigma = std(tmp_distance);
        miu = mean(tmp_distance);
        %delete 2 sigma 
        if size(tmp_distance, 2) ==0
            local_factor_array=[0,0,0,0];
            return 
        end
        kk =1
        while 1 
            if abs(tmp_distance(kk) - miu) > 2*sigma
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
    ab = polyfit(tmp_dist, tmp_snr,1 );
    
    tpc = corrcoef(tmp_dist, tmp_snr);
    R = abs(tpc(2,1));

    %figure
    %{
    figure
    plot(tmp_dist, tmp_snr, 'o')
    hold on
    y = ab(1)*fin_dist + ab(2);
    plot(fin_dist, y, '-')
    hold on
    plot(del_dist, del_snr, '*');
    title(['s ', num2str(sensor),' A ', num2str(ab(1)), ' B ', num2str(ab(2)), ' R ', num2str(R), ' H ', num2str(max(H))])
    
    %}
fin_A = ab(1);
fin_B = ab(2);
fin_R = R;
fin_H = max(H);
fin_fftH = max(FFT_H);
tmp_H = sort(H);
mean_H = nanmean(tmp_H(2:end-1));
fin_bandwidth = NaN(1, 18);
fin_bandwidth = mean(all_bandwidth,2,'omitnan');
fin_bck_bandwidth = mean(all_sub_bck_bandwidth,2,'omitnan');
fin_signal_ECB_bd = mean(all_signal_ECB_bd, 2, 'omitnan');
fin_signal_pse = mean(all_signal_pse, 'omitnan');
local_factor_array=[fin_A,fin_B, fin_R, fin_H, fin_fftH];


SNR_factor = all_path_snr;
SSIM_factor = fin_SSIM;


end