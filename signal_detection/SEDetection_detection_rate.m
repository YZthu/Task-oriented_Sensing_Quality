clear all;
close all;
clc;


data_path ='../detected_mat/';
deployment_name =["Garage", "Aisle_rug", "Bridge"];
sig_name_set =["T", "B1", "B2", "C"];
later_pa ="_recognition_dataset.mat";

bpFilt = designfilt('bandpassfir','FilterOrder',500, ...
     'CutoffFrequency1', 70,'CutoffFrequency2',500, ...
     'SampleRate',6500);
imu_th =[
    74,55,74,44,44,44;
    74,65,65,48,41,42;
    74,65,65,48,41,42;];

bck_start_stop_cell={
    {245800,264500},{250400,266700},{380900,400200},{251700,271700},{251700,266300},{247300,261100};
    {255000,267200},{260000,272200},{260000,272200},{260000,272200},{260000,272200},{455000,460200};
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200};
    };

signal_th =[
   140, 140, 140, 140;
   120, 120, 120, 120;
   180, 180, 180, 180;  
];


load('ground_truth.mat');
for scenario = [1,2,3,6,7,8,9,10,11,12]
    sc_count = scenario;
    if sc_count >3
        sc_count = sc_count -2;
    end
    dataset_path ='../../mat_dataset';
    file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_pa)];
    load(file_name);
    
    
    % SNR constrain from raw signal
    tp_rate =NaN(4,4);
    for vib_type = 1:4
        
        %ground truth label
        ground_truth_loc = cell(1,4);
        for sensor =1:4      
            eval(['tmp_ground =', char(deployment_name(scenario)),'_', char(sig_name_set(vib_type)),'_',num2str(sensor),';'])
            all_ground =[];
            for kk=1:length(tmp_ground)
                all_ground = [all_ground, tmp_ground{kk}];
            end
            ground_truth_loc(sensor) ={all_ground};
        end
        eval(['location_path_interval = ', char(sig_name_set(vib_type)), '_interval;'])
        % test
        detected_num =[];
        for sensor =1:4      
            start_point = location_path_interval(sc_count,1);
            stop_point = location_path_interval(sc_count,end);
            
            eval(['tmp_sig_set =', char(sig_name_set(vib_type)), '_', num2str(sensor), ';']);
            eval(['bck_range = ', char(sig_name_set(vib_type)), '_bck_range;'])
            tmp_sig_set = tmp_sig_set - mean(tmp_sig_set);
            raw_bck = tmp_sig_set(bck_range(sc_count, 1):bck_range(sc_count, 2));
            
            bck_ene = mean(raw_bck.^2);
            if scenario == 8 & vib_type ==4
                tmp_sig_set(131700:199000)= [];
                tmp_sig_set(514400:end) = [];
            end
            
            %SE detection
            [ stepEventsSig, all_stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ,th] = SEDetection( tmp_sig_set, raw_bck, 6);
        
            %constrain the detection on the interval
            idx_flag = (all_stepEventsIdx> start_point) & (all_stepEventsIdx < stop_point);
            stepEventsIdx = all_stepEventsIdx(find(idx_flag==1));
            %det rate
            ground_loc = ground_truth_loc{sensor};
            SE_detected_num = 0;
            SE_detected_loc =[];
            for kk=1:length(stepEventsIdx)
                tmp_sig_loc = stepEventsIdx(kk);
                diff = ground_loc - tmp_sig_loc;
                [min_err, tmp_loc] = min(abs(diff));
                if min_err < 100
                    SE_detected_num = SE_detected_num +1;
                    SE_detected_loc = [SE_detected_loc, tmp_sig_loc];
                    ground_loc(tmp_loc)=[];
                end
            end
            if SE_detected_num > 80
                SE_detected_num = 80;
            end
            % tp SE_detected_num
            % fp + tp length(stepEventsIdx)
            % tp + fn  length(ground_truth_loc{sensor})
            tmp_pre = SE_detected_num ./ length(stepEventsIdx);
            tmp_recall = SE_detected_num ./ length(ground_truth_loc{sensor});
            SE_tp(sensor) = tmp_recall;
            SE_f1(sensor) = 2*tmp_pre*tmp_recall / (tmp_pre + tmp_recall);
            if SE_detected_num == 0
                SE_f1(sensor) = 0;
            end
            
            figure
            plot(tmp_sig_set);
            hold on
            plot(ground_truth_loc{sensor}, 200, '^');
            title(num2str(tmp_pre));
            detected_num(sensor) = 0;
        end
        tp_rate(vib_type,:) = SE_tp;
        f1_sco(vib_type,:) = SE_f1;
    end
   
    fin_tp_rate = mean(tp_rate,1);
    fin_f1_rate = mean(f1_sco,1);
    if max(max(fin_tp_rate)) > 1
        err='e';
    end

    
    eval([char(deployment_name(scenario)),'_tp = fin_tp_rate;']);
    eval([char(deployment_name(scenario)),'_f1 = fin_f1_rate;']);
    if exist('new_detection_rate.mat')
        eval(['save( ''new_detection_rate.mat'',''', char(deployment_name(scenario)),'_tp',''',''', char(deployment_name(scenario)),'_f1' ,''',''-append'')'])
    else
        eval(['save( ''new_detection_rate.mat'',''', char(deployment_name(scenario)), '_tp', ''',''', char(deployment_name(scenario)),'_f1',''')']) 
    end
            
end