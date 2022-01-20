function [sig_loc] = slide_window_detection(current_raw_vs, raw_bck, IMU_path_loc)

sig_loc =[];
    win_size = 1400;
    blackman_w = blackmanharris(win_size);
    sig_ene = current_raw_vs.^2;
    conv_sig = conv(sig_ene, blackman_w);
    bck_conv = conv(raw_bck, blackman_w);
    bak_mean = mean(bck_conv);
    [pks,locs] = findpeaks(conv_sig, 'MinPeakDistance',2000, 'MinPeakHeight', 4*bak_mean);

    %correct locs
    real_loc = locs - round(win_size/2)+1;
    loc_flag = real_loc >0;
    fin_loc = real_loc(find(loc_flag==1));

    
    %use IMU to filtout extra point
    after_flag = fin_loc> IMU_path_loc(1)-6500;
    before_flag = fin_loc < IMU_path_loc(end) + 6500;
    both_flag = after_flag & before_flag;
    sig_loc = fin_loc(find(both_flag==1));
            %{
    figure
    plot(conv_sig)
    hold on
    plot(locs, 0.2*max(conv_sig),'o');
    figure
    plot(current_raw_vs);
    hold on
    plot(sig_loc, 0.4*max(current_raw_vs), 'o');
    %}
end
