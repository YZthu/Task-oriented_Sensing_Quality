function [available_num, tmp_footstep_set,raw_path_vs, fin_selected_sig_loc,current_IMU_path_loc,IMU_vibration_flag] = ...
    new_new_IMU_path_vibration_signal_extract(raw_vs, filted_vs, IMU_path, fil_bck, raw_bck, signal_th, nx, win_size, det_th)


start= max(1,IMU_path(1)-12000);
stop = min(size(filted_vs,2),IMU_path(end)+12000);
step2 = min(stop, size(nx,2));
stop = step2;

current_filted_data = filted_vs(start:stop);
current_raw_vs = raw_vs(start:stop);
current_IMU_path_loc = IMU_path - start+1;
ori_IMU_path = IMU_path -start+1;
IMU_str = nx(start:stop);

 [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ,th] = new_SEDetection( current_raw_vs, raw_bck, det_th, win_size);

        % remove the repeat
         test1 = stepEventsIdx(1:end-1);
        test2 = stepEventsIdx(2:end);
        differ = test2 - test1;
        re_flag = differ < 2000;
        delete_loc =[];
        if sum(re_flag)> 0
            %delete repeat
            re_loc = find(re_flag==1);
            kk = length(re_loc);
            while kk>0
                
                tmp_loc = re_loc(kk);
                tmp_c=find(re_loc==tmp_loc-1);
                if length(tmp_c)>0
                    %stepEventsIdx(tmp_loc)=[];
                    delete_loc = [delete_loc,tmp_loc];
                    kk=kk-2;
                    continue;
                end
                
                loc1= stepEventsIdx(tmp_loc);
                loc2= stepEventsIdx(tmp_loc+1);
                if loc2-loc1 > 50
                    amp1 = max(current_raw_vs(loc1-25:loc1+25));
                    amp2 = max(current_raw_vs(loc2-25:loc2+25));
                else
                    cent= round((loc1+loc2)/2);
                    amp1 = max(current_raw_vs(loc1-25:cent));
                    amp2 = max(current_raw_vs(loc2-cent:loc2+25));
                end
                if amp1> amp2
                    %stepEventsIdx(tmp_loc+1)=[];
                    
                    delete_loc = [delete_loc,tmp_loc+1];
                else
                    %stepEventsIdx(tmp_loc)=[];
                    
                    delete_loc = [delete_loc,tmp_loc];
                end
                kk=kk-1;
            end
            stepEventsIdx(delete_loc)=[];
        end
    %{
 figure
 plot(current_raw_vs);
 hold on
 plot(stepEventsIdx, 200,'*');
 
  figure
 plot(abs(windowEnergyArray(:,1)-noiseMu));
 hold on
 plot(1:size(windowEnergyArray,1), noiseSigma*det_th,'o');
%}
 
        if length(stepEventsIdx) < 3
            %no excitation detected
            tmp_footstep_set =[];
            for tmp_sig_n =1:size(IMU_path,2)
                current_sig_loc = current_IMU_path_loc(tmp_sig_n);
                if current_sig_loc+1300-1 > size(current_raw_vs,2)
                    %break;
                end
                tmp_signal = current_raw_vs(current_sig_loc-200: current_sig_loc+1300-1);
                tmp_footstep_set = [tmp_footstep_set; tmp_signal];
            end
            
            available_num = size(tmp_footstep_set,1);
            raw_path_vs =[];
            fin_selected_sig_loc = IMU_path;
            IMU_vibration_flag = zeros(1, 1);
            return
        end
%[signals, stepEventsIdx] = partial_signal_extract( current_raw_vs, 300, signal_th, 0);

%{
    tmp_sig_set = stepEventsIdx;
    sig_num = size(current_IMU_path_loc,2);
    figure
    plot(current_raw_vs);
    hold on
    sig_flag = ones(1, length(tmp_sig_set))* 0.7*max(current_raw_vs);
    plot(tmp_sig_set, sig_flag, '*');
    hold on
    sig_flag = ones(1, length(current_IMU_path_loc))* 0.5*max(current_raw_vs);
    plot(current_IMU_path_loc, sig_flag, 'o');
    legend('filted sig', 'raw sig', 'IMU sig')
  %}
tmp_sig_set = stepEventsIdx;
sig_num = size(current_IMU_path_loc,2);
distance_array =[];
count = 0;
while 1
    count = count +1;
    minus_count = 0;
    positive_count = 0;
    m_index =[];
    p_index =[];
    array_count = 0;
    distance_array=[];
    for IMU_foot_num  =1:sig_num

            tmp_loc = current_IMU_path_loc(IMU_foot_num);
            [tmp_v, t_loc] = min(abs(tmp_sig_set - tmp_loc));
            if tmp_v > 1700
                continue;
            end
            array_count = array_count +1;
            tmp_err = tmp_sig_set(t_loc) - tmp_loc;
            if tmp_err > 0
                positive_count = positive_count +1;
                p_index =[p_index, array_count];
            else
                minus_count = minus_count +1;
                m_index = [m_index, array_count];
            end
             distance_array = [distance_array,abs(tmp_err)];
    end
    [v, loc] = sort(abs(distance_array));
    if length(distance_array)> 5
        mean_error = mean(distance_array(loc(3:end-2)));
    else
        if length(distance_array) >2
            mean_error = mean(distance_array(loc(2:end-1)));
        else 
            mean_error = mean(distance_array);
        end
    end
    new_IMU_path_loc = current_IMU_path_loc + mean_error;
    if mean(distance_array) < 200 | count > 10
        break;
    else
        if  positive_count > minus_count 
            current_IMU_path_loc = current_IMU_path_loc + 0.7*mean(distance_array(p_index));
        else
            current_IMU_path_loc = current_IMU_path_loc - 0.7*mean(distance_array(m_index));
        end
    end
end


new_distance =[];
detected_sig_loc =NaN(1,sig_num);
IMU_vibration_flag = zeros(1, sig_num);
for IMU_foot_num  =1:sig_num

        tmp_loc = new_IMU_path_loc(IMU_foot_num);
        [tmp_v, t_loc] = min(abs(tmp_sig_set - tmp_loc));
         new_distance(IMU_foot_num) = tmp_sig_set(t_loc) - tmp_loc;
         if tmp_v > 1500
             continue;
         else
             detected_sig_loc(IMU_foot_num) = tmp_sig_set(t_loc);
             IMU_vibration_flag(IMU_foot_num) = 1;
         end
             
end
%{
    figure
    plot(current_raw_vs);
    hold on
   % plot(IMU_str)
    hold on
    sig_flag = ones(1, sig_num)* 0.8*max(current_raw_vs);
    plot(detected_sig_loc, sig_flag, '*');
    hold on
    sig_flag1 = ones(1, length(tmp_sig_set))* 0.7*max(current_raw_vs);
    plot(tmp_sig_set, sig_flag1, '^');
    hold on
    plot(new_IMU_path_loc, 0.7*sig_flag, 'o');
    hold on
    sig_flag = ones(1, length(current_IMU_path_loc))* 0.5*max(current_raw_vs);
    plot(current_IMU_path_loc, sig_flag, 'd');
    legend('vib', 'fin sig', 'det sig', 'new IMU', 'old IMU')
    title(num2str(count));
            %}
    detected_sig_loc;

% detected sig filterout

tmp_footstep_set = [];
selected_sig_loc =[];
available_num =0;
 all_sig =[];
 sig_energy =NaN(1,size(detected_sig_loc,2));
for need_sig =1:size(detected_sig_loc,2)
    current_sig_loc = detected_sig_loc(need_sig);
    if isnan(current_sig_loc)   
        tmp_signal = NaN(1,1500);
        tmp_en =NaN;
    else
        tmp_signal = current_raw_vs(current_sig_loc-200: current_sig_loc+1300-1);
        available_num = available_num+1;
        tmp_en = mean(tmp_signal.^2);
    end

    selected_sig_loc = [selected_sig_loc, current_sig_loc];
    tmp_footstep_set(need_sig,:) =tmp_signal;
    all_sig = [all_sig, tmp_signal];
    all_sig = [all_sig, zeros(1,4000)];
    sig_energy(need_sig) = tmp_en;
end
 fin_selected_sig_loc = selected_sig_loc;
 %raw_path_vs = raw_vs(fin_start:fin_stop);
 raw_path_vs = current_raw_vs;
 if length(raw_path_vs)> 80000
     err='e'
 end
 %{
    figure
    plot(current_raw_vs);
    hold on
    sig_flag = ones(1, length(selected_sig_loc))* 0.8*max(current_raw_vs);
    plot( selected_sig_loc, sig_flag, '*');
    %hold on
    %plot(all_sig)
    %}
end