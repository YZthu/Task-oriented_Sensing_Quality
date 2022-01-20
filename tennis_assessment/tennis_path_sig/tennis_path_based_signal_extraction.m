function [BCK, raw_BCK, path_sig_set, path_sig_ts,path_sig_wv, path_sig_loc_set] = tennis_path_based_signal_extraction(sensor, scenario, raw_sig, bck_loc, raw_sig_ts)

bpFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 70,'CutoffFrequency2',500, ...
         'SampleRate',6500);



distance_set=[3,2,1]; % feet
%delete the footstep 80~ 90s and 170~180 and last 40seconds empty data.
total_time = size(raw_sig,2)/6500;
if total_time < 230
    err='data length wrong!'
    return;
end

raw_bcknoise= raw_sig(bck_loc(1):bck_loc(2));
filted_bck = filtfilt(bpFilt, raw_bcknoise);
BCK = mean(raw_bcknoise.^2);
raw_BCK = raw_bcknoise;

sampling_rate = round(size(raw_sig,2)/300);
%{
footstep1 = 78*sampling_rate:88*sampling_rate;
footstep2 = (168)*sampling_rate:(178)*sampling_rate;
empty1 = (262)*sampling_rate:size(raw_sig,2);
raw_sig(empty1) = [];
raw_sig(footstep2) = [];
raw_sig(footstep1) = [];
%}
filted_sig1 = filtfilt(bpFilt, raw_sig);
%{
figure
plot(filted_sig1)
%}
sig_win1 = 200;
sig_win2 = 800;


%{
figure
plot(bck11);
title('bck')
figure
plot(filted_sig1);
title('filted sig')
%}

time_len = size(filted_sig1,2)/6500;
if time_len < 235
    err='data length not enough'
    return
end

path_time_stamp = linspace(0, time_len, 25);
path_loc_interval = round(path_time_stamp*6500)+0;
path_loc_interval(1)=1;
if path_loc_interval(end)> length(filted_sig1)
    path_loc_interval(end)= length(filted_sig1);
end
figure
plot(filted_sig1)
hold on
plot(path_loc_interval,10,'o');

path_sig_set ={};
path_sig_ts ={};
path_sig_wv ={};
path_sig_loc_set = {};
all_loc =[];
for path_num = 1:24
    path_num;
    tmp_path_filted_data = filted_sig1(path_loc_interval(path_num):path_loc_interval(path_num+1));
    tmp_path_raw_data = raw_sig(path_loc_interval(path_num):path_loc_interval(path_num+1));
   % tmp_path_raw_ts = raw_sig_ts(path_loc_interval(path_num):path_loc_interval(path_num+1));
    tmp_path_raw_ts =[];
    if path_num <8
        e='ee';
    end
    
    bck_th =8;
    if scenario ==5 & sensor ==3
        bck_th =5;
    end
    if scenario ==6
        bck_th = 4;
    end
    if scenario ==6 & sensor ==2
        bck_th = 2;
    end
    if scenario ==7
        bck_th =8;
    end
    [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ,th] = SEDetection( tmp_path_filted_data, filted_bck, bck_th);
    if scenario == 11 & sensor >4
        [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ,th] = SEDetection_narrow( tmp_path_filted_data, filted_bck, bck_th);
    end
    %}
    %[stepEventsSig, stepEventsIdx] = partial_signal_extract( current_raw_vs, 300, signal_th, 0);
    %{
    figure
    plot( tmp_path_filted_data);
    figure
    plot(windowEnergyArray(:,1)-noiseMu);
    hold on
    xx=ones(1, size(windowEnergyArray,1))*noiseSigma*bck_th;
    plot(xx, 'o')
    title(num2str(path_num))
    %}
    
    
    tmp_path_set = tennis_path_detection( stepEventsIdx', 6000, 6);
    if scenario ==9 & path_num==1
        tmp_path_set = tennis_path_detection( stepEventsIdx', 8000, 6);
    end
    tmp_path_set;
    
    if size(tmp_path_set, 2) ~= 1
        tmp_path_set
        err='multiple path detected';
        %continue;
    end
    % excitation selection
    if length(tmp_path_set) < 1
            path_sig_set(path_num) ={NaN};
        path_sig_ts(path_num) = {NaN};
        path_sig_wv(path_num) = {NaN};
        continue;
    end
    new_path = [];
    
    if length(tmp_path_set)> 1
        len=[];
        
        for kk=1:length(tmp_path_set)
            tmp_set_len = size(tmp_path_set{kk} ,2);
            len(kk) = tmp_set_len;
        end
        [~, sel]= max(len);
        tmp_path = cell2mat(tmp_path_set(sel));
    else
        tmp_path = cell2mat(tmp_path_set(1));
    end
    %{
    if size(tmp_path,2) <11
        new_path = tmp_path;
    else
        amp =[];
        for ind = 1:size(tmp_path,2)
            if (tmp_path(ind)-sig_win1 < 1 ) |(tmp_path(ind)+sig_win1 > size(tmp_path_filted_data,2))
                continue;
            end
            tmp_sig = tmp_path_raw_data(tmp_path(ind)-50: tmp_path(ind)+50);
            tmp_amp = max(tmp_sig);
            amp = [amp, tmp_amp];
        end
    
        [~, id] = sort(abs(amp-mean(amp)),'ascend');
        if size(id,2) > 10
        new_path = tmp_path(id(1:10));
        else
            new_path = tmp_path;
        end
    end
    %}

                while 1
                    path_interval = tmp_path(2:end) - tmp_path(1:end-1);
                    interval_sort = sort(path_interval);
                    standard_interval =0;
                    standard_interval = mean(interval_sort(3:end-3));

                    outlier =[];
                    for int_num =2:length(path_interval)-1
                        current_interval = path_interval(int_num);
                        before_int = path_interval(int_num-1);
                        later_int = path_interval(int_num+1);
                        problem_point = 0;
                        if current_interval< 0.7*standard_interval
                            if before_int > later_int
                                problem_point = int_num +1;
                                
                            else
                                problem_point = int_num;
                            end
                            
                        end
                        if problem_point > 0
                            outlier = [outlier, problem_point];
                            break
                        end
                    end
                    if length(outlier) < 1
                        break;
                    end
                    %delete outlier
                    c = unique(outlier);
                    if length(outlier)>0
                        e='e'
                    end
                    tmp_path(outlier) =[];

                end
                new_location_loc = tmp_path;
                outlier =[];
                if length(new_location_loc)>10
                    if path_interval(1) > 1.4*standard_interval
                        outlier =[outlier,1];
                    end
                    if path_interval(end) > 1.4*standard_interval
                        outlier =[outlier,length(tmp_path)];
                    end
                    if path_interval(1) < 0.8*standard_interval
                        outlier =[outlier,1];
                    end
                    if path_interval(end) < 0.8*standard_interval
                        %outlier =[outlier,length(tmp_location_loc)];
                    end
                end
                outlier = unique(outlier);
                if length(outlier)>0
                        e='e'
                    end
                tmp_path(outlier) =[];
                
                
                if length(tmp_path)> 11
                    %filtout based on amplitude
                    while 1
                        sig_max=[];
                        raw_peak =[];
                        for tmp_c =1:length(tmp_path)
                            tmp_loc = tmp_path(tmp_c);
                            start_dd = max(1, tmp_loc-100);
                            stop_dd = min(length(tmp_path_filted_data), tmp_loc+150);
                            sig_max(tmp_c) = max(tmp_path_filted_data(start_dd:stop_dd));
                            raw_peak(tmp_c) = sqrt(mean(tmp_path_filted_data(start_dd:stop_dd).^2));
                        end
                        b =sort(sig_max);
                        d = sort(raw_peak);
                        mean_amp = mean(b(2:end-2));
                        mean_energy = mean(d(2:end-2));
                        del_st =[];
                        
                        [v, loc] = max(sig_max-mean_amp);
                        if  v > 0.4*mean_amp
                            del_st = loc;
                        end
                        %min detection
                        [v, loc] = min(sig_max-mean_amp);
                        
                        if  v < -0.3*mean_amp
                            del_st = [del_st, loc];
                        end
                        [rv, loc2]= min(raw_peak- mean_energy);
                        
                            if rv < -0.3*mean_energy
                                del_st = [del_st, loc2];
                            end
                        del_st = unique(del_st);
                        if length(del_st) ==0
                            break;
                        else
                            tmp_path(del_st) =[];
                        end
                        if length(tmp_path)<6
                            break;
                        end
                    end
                end
    sig_loc_set = tmp_path;
   
    if length(sig_loc_set)< 9
        e='eee';
    end
    tmp_sig_set =[];
    tmp_sig_ts =[];
    tmp_sig_wv =[];
    for sig_number =1:size(sig_loc_set,2)
        if (sig_loc_set(sig_number)-sig_win1 -1000 < 1) | (sig_loc_set(sig_number)+sig_win2 -1 +1000> size(tmp_path_raw_data,2))
            continue;
        end
        tmp_sig = tmp_path_raw_data(sig_loc_set(sig_number)-sig_win1:sig_loc_set(sig_number)+sig_win2 -1);
        tmp_wv = tmp_path_raw_data(sig_loc_set(sig_number)-sig_win1-1000:sig_loc_set(sig_number)+sig_win2 -1 + 1000);
        %tmp_ts = tmp_path_raw_ts(sig_loc_set(sig_number)-sig_win1:sig_loc_set(sig_number)+sig_win2 -1);
        tmp_ts = NaN;
        tmp_sig_set =[tmp_sig_set; tmp_sig];
        tmp_sig_ts = [tmp_sig_ts; tmp_ts];
        tmp_sig_wv = [tmp_sig_wv; tmp_wv];
        
    end
    %if mod(path_num, 3) ==0
    %{
    figure
    plot(tmp_path_filted_data);
    hold on
    plot(sig_loc_set, 0.65*max(tmp_path_filted_data), '*')
    hold on 
    plot(cell2mat(tmp_path_set(1)), 0.5*max(tmp_path_filted_data), 'o')
    t='t';
    title(num2str(path_num)) 
    %}
    %end
    path_sig_set(path_num) ={tmp_sig_set};
    path_sig_ts(path_num) = {tmp_sig_ts};
    path_sig_wv(path_num) = {tmp_sig_wv};
    path_sig_loc_set(path_num) = {sig_loc_set + path_loc_interval(path_num)-1};
    all_loc = [all_loc, sig_loc_set + path_loc_interval(path_num)-1];
end
%{
figure
plot(raw_sig)
hold on
plot(all_loc, 0.5*max(raw_sig), 'o')
%}
end