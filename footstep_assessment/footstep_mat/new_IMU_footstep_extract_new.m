clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
later_part ="_footstep_dataset.mat"
dataset_path ='../../mat_dataset';

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
    {255000,267200},{260000,272200},{260000,272200},{260000,272200},{260000,272200},{455000,460200};
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
         'CutoffFrequency1', 180,'CutoffFrequency2',500, ...
         'SampleRate',6500);
teFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 180,'CutoffFrequency2',600, ...
         'SampleRate',6500);
     
obj_name=["Y_S1","Y_S2","Y_S3","K_S1","K_S2","K_S3"];

for scenario = [10,11]
file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_part)];
load(file_name);

    later_pa ="_footstep_SE.mat";
    file_na = ['./', char(deployment_name(scenario)), char(later_pa)]
    save(file_na, 'file_name');
    
for tmp_obj_num = 1:length(obj_name)
    eval(['vs1 = ', char(obj_name(tmp_obj_num)), '_1;'])
    eval(['vs2 = ', char(obj_name(tmp_obj_num)), '_2;'])
    eval(['vs3 = ', char(obj_name(tmp_obj_num)), '_3;'])
    eval(['vs4 = ', char(obj_name(tmp_obj_num)), '_4;'])
    %eval(['IX = ', char(obj_name(tmp_obj_num)), '_1_IMU_X;'])
    %eval(['IY = ', char(obj_name(tmp_obj_num)), '_1_IMU_Y;'])
    %eval(['IZ = ', char(obj_name(tmp_obj_num)), '_1_IMU_Z;'])
    if scenario > 9
        eval(['vs5 = ', char(obj_name(tmp_obj_num)), '_5;'])
        eval(['vs6 = ', char(obj_name(tmp_obj_num)), '_6;'])
    end
    
    if scenario >3
        eval(['IX = ', char(obj_name(tmp_obj_num)), '_IMU_X;'])
        eval(['IY = ', char(obj_name(tmp_obj_num)), '_IMU_Y;'])
        eval(['IZ = ', char(obj_name(tmp_obj_num)), '_IMU_Z;'])
    else
        eval(['IX = ', char(obj_name(tmp_obj_num)), '_1_IMU_X;'])
        eval(['IY = ', char(obj_name(tmp_obj_num)), '_1_IMU_Y;'])
        eval(['IZ = ', char(obj_name(tmp_obj_num)), '_1_IMU_Z;'])
    end
    
    vs1 = vs1 - mean(vs1);
    vs2 = vs2 - mean(vs2);
    vs3 = vs3 - mean(vs3);
    vs4 = vs4 - mean(vs4);
    X = IZ - mean(IZ);
    
    filted_vs1 = filtfilt(bpFilt, vs1);
    filted_vs2 = filtfilt(bpFilt, vs2);
    filted_vs3 = filtfilt(bpFilt, vs3);
    filted_vs4 = filtfilt(bpFilt, vs4);
    
    %{
    filted_vs1 = wiener2(vs1, [1 150]);
    filted_vs2 = wiener2(vs2, [1 150]);
    filted_vs3 = wiener2(vs3, [1 150]);
    filted_vs4 = wiener2(vs4, [1 150]);
    %}
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
    
    sensor_number =4;
    if scenario >9
        sensor_number = 6;
    end
    for sensor =1:sensor_number
    % resample IMU data
    eval(['tmp_vs = vs', num2str(sensor),';'])
    eval(['tmp_filted_vs = filted_vs', num2str(sensor),';'])
    eval(['tmp_filted_bck = filted_bck', num2str(sensor),';'])
    eval(['tmp_blank = blank', num2str(sensor),';'])
    
    NX1 = resample(X, round(size(tmp_vs,2)/size(X,2)*800), 800);
    
    tmpl = [size(NX1,2), size(tmp_vs,2)];
    avail_len = min(tmpl);
    
    nvs1 = tmp_vs(1:avail_len);
    nx1 = NX1(1:avail_len);

    
    %filted_x = filtfilt(IMUbpFilt, nx);
    %{
    figure
    plot(nx);
    hold on
    plot(nvs1);
    legend('IMU', 'vibiration')
    %}

    [signals, imu_sig_loc1] = partial_signal_extract(nx1, 300, imu_th(scenario,tmp_obj_num), 0);
    IMU_path_set1 = path_detection(imu_sig_loc1, 7000, 4);
    
    %path_plot(nx1, imu_sig_loc1, IMU_path_set1)
    
    path_number = size(IMU_path_set1,2)
    if path_number ~= PATH
        err='path number wrong line 138'
        %return
    end
    if scenario==8 & tmp_obj_num==2
        path_number =12;
    end
        
    foot_path_set={};
    raw_path_vs = {};
    path_sig_loc = {};
    total_sig_num =[];
    filted_path_set={};
    filted_sig_num=[];
    for path_num =1:path_number
        tmp_IMU_path1 = cell2mat(IMU_path_set1(path_num));

        % missing detection
        test1 = tmp_IMU_path1(1:end-1);
        test2 = tmp_IMU_path1(2:end);
        differ = test2 - test1;
        if size(differ,2) > 11
        differ = differ(1:11);
        end
        if max(differ) > 7000
            err='IMU signal detection wrong'
            return;
        end
        
        
        if size(tmp_IMU_path1,2)<7
            err="can not detecte a available path"
            continue;
            %return
        end     

        new_IMU_path = tmp_IMU_path1;
        
        
        %[sig_num1, tmp_footstep_set1, raw_path_vs1, path_sig_loc1, IMU_loc1] = new_IMU_path_vibration_signal_extract(tmp_vs, tmp_filted_vs, new_IMU_path,tmp_filted_bck, tmp_blank, signal_th(scenario, sensor), nx1);
        windowSize =800;
        if scenario ==7
            windowSize = 600;
        end
        [sig_num1, tmp_footstep_set1, raw_path_vs1, path_sig_loc1, IMU_loc1] = ...
            new_IMU_path_vibration_signal_extract(tmp_vs, tmp_filted_vs, new_IMU_path,tmp_filted_bck, tmp_blank, 180, nx1);
        
        if scenario ==2
            [sig_num1, tmp_footstep_set1, raw_path_vs1, path_sig_loc1, IMU_loc1] = new_new_IMU_path_vibration_signal_extract(tmp_vs, tmp_filted_vs, new_IMU_path,tmp_filted_bck, tmp_blank, 180, nx1,2500,3.5);
        end
        
        if scenario ==4
            %[sig_num1, tmp_footstep_set1, raw_path_vs1, path_sig_loc1, IMU_loc1] = new_new_IMU_path_vibration_signal_extract(tmp_vs, tmp_filted_vs, new_IMU_path,tmp_filted_bck, tmp_blank, signal_th(scenario, sensor), nx1,2500,3.5);
        end
        %[filted_sig_num1, filted_footstep_set1, raw_path_vs1, path_sig_loc1, IMU_loc1] = filted_IMU_path_vibration_signal_extract(tmp_vs, tmp_filted_vs, new_IMU_path,tmp_filted_bck, tmp_blank, signal_th(scenario, sensor), nx1);
        
        %[sig_num2, tmp_footstep_set2, raw_path_vs2, path_sig_loc2, IMU_loc2] = new_IMU_path_vibration_signal_extract(vs2, filted_vs2, new_IMU_path,filted_bck2, blank2, signal_th(scenario, 2), nx1);
        %[sig_num3, tmp_footstep_set3, raw_path_vs3, path_sig_loc3, IMU_loc3] = new_IMU_path_vibration_signal_extract(vs3, filted_vs3, new_IMU_path,filted_bck3, blank3, signal_th(scenario, 3), nx1);
        %[sig_num4, tmp_footstep_set4, raw_path_vs4, path_sig_loc4, IMU_loc4] = new_IMU_path_vibration_signal_extract(vs4, filted_vs4, new_IMU_path,filted_bck4, blank4, signal_th(scenario, 4), nx1);
        %{
        figure
        plot(raw_path_vs1)
        hold on
        plot(path_sig_loc1, 200,'o')
        hold on
        plot(IMU_loc1, 150, '*')
        %}
        sig_num1;
        if sig_num1<6
            e='e';
        end

        foot_path_set( path_num)={tmp_footstep_set1};
        raw_path_sig(path_num) = {raw_path_vs1};
        path_sig_loc(path_num) = {path_sig_loc1};
        
        total_sig_num( path_num) = sig_num1;
    end
    total_sig_num
    %filted_sig_num
    
    eval([char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_ftst = foot_path_set;'])
    eval([char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_bck = blank', num2str(sensor),';'])
    eval([char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_raw_path_vs = raw_path_sig;'])
    eval([char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_path_log = path_sig_loc;'])
    
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)),'_',num2str(sensor),'_ftst'',''-append'');']);
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_bck'',''-append'');']);
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_raw_path_vs'',''-append'');']);
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)), '_',num2str(sensor),'_path_log'',''-append'');']);
    %save(file_name,'BCK','foot_path_set', 'raw_bck', 'raw_path_vs', 'path_sig_loc');
    end
end

end