clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

later_part ="_footstep_dataset.mat"
dataset_path ='../mat_dataset';

imu_th =[
    74,55,74,44,44,44;
    74,65,65,48,41,42;
    74,65,65,48,41,42; %3
    74,55,65,38,41,42; %4
    74,65,65,48,41,42; %5
    50,50,50,48,41,42; %6
    48,33,56,48,41,42; %7
    74,65,65,48,41,42; %8
    56,56,65,48,41,42; %9
    54,56,65,48,41,42; %10
    56,56,65,48,41,42; %11
    ];

bck_start_stop_cell={
    {245800,264500},{250400,266700},{380900,400200},{251700,271700},{251700,266300},{247300,261100};
    {255000,267200},{260000,268200},{255000,267200},{255000,267200},{255000,267200},{250000,260000};
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %3
    {255000,266200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %4
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %5
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %6
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %7
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %8
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %9
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %10
    {255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200},{255000,267200}; %11
    };

signal_th =[
   140, 140, 140, 140;
   120, 120, 120, 120;
   180, 180, 180, 180;  %3
   180, 180, 180, 180;  %4
   180, 180, 180, 180;  %5
   180, 180, 180, 180;  %6
   180, 180, 180, 180;  %7    
   180, 180, 180, 180;  %8
   180, 180, 180, 180;  %9
];


bpFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 40,'CutoffFrequency2',500, ...
         'SampleRate',6500);
IMUbpFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 5,'CutoffFrequency2',50, ...
         'SampleRate',6500);
     
obj_name=["Y_S1","Y_S2","Y_S3","K_S1","K_S2","K_S3"];
select_obj =[2,3,5,6];
%obj_name=["Y_S2","Y_S3","K_S2","K_S3"];

for scenario = [10:11]
file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_part)];
load(file_name);
    tp_rate = [];
    f1_sco = [];
for sele_num = 1:length(select_obj)
    tmp_obj_num = select_obj(sele_num);
    eval(['vs1 = ', char(obj_name(tmp_obj_num)), '_1;'])
    eval(['vs2 = ', char(obj_name(tmp_obj_num)), '_2;'])
    eval(['vs3 = ', char(obj_name(tmp_obj_num)), '_3;'])
    eval(['vs4 = ', char(obj_name(tmp_obj_num)), '_4;'])
    if scenario > 9
        eval(['vs5 = ', char(obj_name(tmp_obj_num)), '_5;'])
        eval(['vs6 = ', char(obj_name(tmp_obj_num)), '_6;'])
    end
    
    if scenario < 4
        eval(['IX = ', char(obj_name(tmp_obj_num)), '_1_IMU_X;'])
        eval(['IY = ', char(obj_name(tmp_obj_num)), '_1_IMU_Y;'])
        eval(['IZ = ', char(obj_name(tmp_obj_num)), '_1_IMU_Z;'])
    else
        eval(['IX = ', char(obj_name(tmp_obj_num)), '_IMU_X;'])
        eval(['IY = ', char(obj_name(tmp_obj_num)), '_IMU_Y;'])
        eval(['IZ = ', char(obj_name(tmp_obj_num)), '_IMU_Z;'])
    end
    
    vs1 = vs1 - mean(vs1);
    vs2 = vs2 - mean(vs2);
    vs3 = vs3 - mean(vs3);
    vs4 = vs4 - mean(vs4);
    X = IZ - mean(IZ);
    %{
    filted_vs1 = filtfilt(bpFilt, vs1);
    filted_vs2 = filtfilt(bpFilt, vs2);
    filted_vs3 = filtfilt(bpFilt, vs3);
    filted_vs4 = filtfilt(bpFilt, vs4);
    %}
    
    filted_vs1 = wiener2(vs1, [1 150]);
    filted_vs2 = wiener2(vs2, [1 150]);
    filted_vs3 = wiener2(vs3, [1 150]);
    filted_vs4 = wiener2(vs4, [1 150]);
    
    bck_start_stop = cell2mat(bck_start_stop_cell{scenario, tmp_obj_num});
    filted_bck1 = filted_vs1(bck_start_stop(1):bck_start_stop(2));
    filted_bck2 = filted_vs2(bck_start_stop(1):bck_start_stop(2));
    filted_bck3 = filted_vs3(bck_start_stop(1):bck_start_stop(2));
    filted_bck4 = filted_vs4(bck_start_stop(1):bck_start_stop(2));
    % Back ground noise
    
    blank1=vs1(bck_start_stop(1):bck_start_stop(2));
    blank2=vs2(bck_start_stop(1):bck_start_stop(2));
    blank3=vs3(bck_start_stop(1):bck_start_stop(2));
    blank4=vs4(bck_start_stop(1):bck_start_stop(2));
    
    bck1 = mean(blank1.^2);
    bck2 = mean(blank2.^2);
    bck3 = mean(blank3.^2);
    bck4 = mean(blank4.^2);
    BCK =[bck1, bck2,bck3, bck4];
    raw_bck=[{blank1}, {blank2}, {blank3}, {blank4}];
    
    if scenario >9
        vs5 = vs5 - mean(vs5);
        vs6 = vs6 - mean(vs6);
        filted_vs5 = filtfilt(bpFilt, vs5);
        filted_vs6 = filtfilt(bpFilt, vs6);
    
        filted_bck5 = filted_vs5(bck_start_stop(1):bck_start_stop(2));
        filted_bck6 = filted_vs6(bck_start_stop(1):bck_start_stop(2));
        blank5=vs5(bck_start_stop(1):bck_start_stop(2));
        blank6=vs6(bck_start_stop(1):bck_start_stop(2));
        bck5 = mean(blank5.^2);
        bck6 = mean(blank6.^2);
        BCK =[BCK, bck5, bck6];
        raw_bck =[raw_bck, {blank5}, {blank6}];
    end
    
    % correct x
    xlen = size(X,2)/800;
    PATH = 18;
    if xlen < 150
        X = [X, zeros(1,48000)];
        PATH = 12
    end
    sen_number= 4;
    if scenario > 9
        sen_number = 6
    end
    for sensor =1:sen_number
    % resample IMU data
        eval(['tmp_vs = vs', num2str(sensor),';'])
        eval(['tmp_filted_vs = filted_vs', num2str(sensor),';'])
        eval(['tmp_filted_bck = filted_bck', num2str(sensor),';'])
        eval(['tmp_blank = blank', num2str(sensor),';'])

        NX1 = resample(X, round(size(tmp_vs,2)/size(X,2)*800), 800);

        tmpl = [size(NX1,2), size(tmp_vs,2)];
        avail_len = min(tmpl);

        nvs1 = tmp_vs(1:avail_len);
        nx = NX1(1:avail_len);
    

        %IMU footstep detection
    [signals, sig_loc] = partial_signal_extract(nx, 300, imu_th(scenario,tmp_obj_num), 0);
    IMU_path_set = path_detection(sig_loc, 7000, 4);
    %path_plot(nx, sig_loc, IMU_path_set)
    
    path_number = size(IMU_path_set,2)
    if path_number ~= PATH
        err='path number wrong line 65'
        return
    end
    foot_path_set={};
    raw_path_vs = {};
    path_sig_loc = {};
    total_sig_num =[];
    IMU_ground_truth=[];
    for path_num =1:path_number
        tmp_IMU_path = cell2mat(IMU_path_set(path_num));
        
        
        new_IMU_path = tmp_IMU_path;
        if size(new_IMU_path,2)<7
            err="can not detecte a available path"
            return
        end     
        IMU_ground_truth =[IMU_ground_truth, tmp_IMU_path];
    end

    %Vibration detection
     [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
                stepStartIdxArray, stepStopIdxArray, ... 
                windowEnergyArray, noiseMu, noiseSigma, noiseRange ,th] = SEDetection( tmp_vs, tmp_blank, 8);
    %detection rate
    %det rate
        ground_loc = IMU_ground_truth;
        SE_detected_num = 0;
        SE_detected_loc =[];
        for kk=1:length(stepEventsIdx)
            tmp_sig_loc = stepEventsIdx(kk);
            diff = ground_loc - tmp_sig_loc;
            [min_err, tmp_loc] = min(abs(diff));
            if min_err < 500
                SE_detected_num = SE_detected_num +1;
                SE_detected_loc = [SE_detected_loc, tmp_sig_loc];
                ground_loc(tmp_loc)=[];
            end
        end
        if SE_detected_num > 80
            %SE_detected_num = 80;
        end
        % tp SE_detected_num
        % fp + tp length(stepEventsIdx)
        % tp + fn  length(ground_truth_loc{sensor})
        tmp_pre = SE_detected_num ./ length(stepEventsIdx);
        tmp_recall = SE_detected_num ./ length(IMU_ground_truth);
        if tmp_recall > 1
            %tmp_recall=1;
        end
        SE_tp(sensor) = tmp_recall;
        SE_f1(sensor) = 2*tmp_pre*tmp_recall / (tmp_pre + tmp_recall);
        if SE_detected_num == 0
            SE_f1(sensor) = 0;
        end
    end
    tp_rate(sele_num,:) = SE_tp;
    f1_sco(sele_num,:) = SE_f1;
end
    fin_tp_rate = mean(tp_rate,1);
    fin_f1_rate = mean(f1_sco,1);
    if max(max(fin_tp_rate)) > 1
        err='e';
    end

    
    eval([char(deployment_name(scenario)),'_tp = fin_tp_rate;']);
    eval([char(deployment_name(scenario)),'_f1 = fin_f1_rate;']);
    if exist('new_detection_rate_8.mat')
        eval(['save( ''new_detection_rate_8.mat'',''', char(deployment_name(scenario)),'_tp',''',''', char(deployment_name(scenario)),'_f1' ,''',''-append'')'])
    else
        eval(['save( ''new_detection_rate_8.mat'',''', char(deployment_name(scenario)), '_tp', ''',''', char(deployment_name(scenario)),'_f1',''')']) 
    end
end

