clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge"];
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
    };

signal_th =[
   140, 140, 140, 140;
   120, 120, 120, 120;
   180, 180, 180, 180;  
];

bpFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 40,'CutoffFrequency2',500, ...
         'SampleRate',6500);
     
obj_name=["Y_S1","Y_S2","Y_S3","K_S1","K_S2","K_S3"];

for scenario = [1,2,3]
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
    eval(['IX = ', char(obj_name(tmp_obj_num)), '_1_IMU_X;'])
    eval(['IY = ', char(obj_name(tmp_obj_num)), '_1_IMU_Y;'])
    eval(['IZ = ', char(obj_name(tmp_obj_num)), '_1_IMU_Z;'])
    
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

    % correct x
    xlen = size(X,2)/800;
    PATH = 18;
    if xlen < 150
        X = [X, zeros(1,48000)];
        PATH = 12
    end
    
    % resample IMU data
    NX = resample(X, round(size(vs1,2)/size(X,2)*800), 800);
    tmpl = [size(NX,2), size(vs1,2), size(vs2,2), size(vs3,2), size(vs4,2)];
    avail_len = min(tmpl);
    
    nvs1 = vs1(1:avail_len);
    nvs2 = vs2(1:avail_len);
    nvs3 = vs3(1:avail_len);
    nvs4 = vs4(1:avail_len);
    nx = NX(1:avail_len);
    
    %filted_x = filtfilt(IMUbpFilt, nx);
    %{
    figure
    plot(nx);
    hold on
    plot(nvs1);
    legend('IMU', 'vibiration')
    %}

    [signals, sig_loc] = partial_signal_extract(nx, 300, imu_th(scenario,tmp_obj_num), 0);
    IMU_path_set = path_detection(sig_loc, 7000, 4);
    path_plot(nx, sig_loc, IMU_path_set)
    
    path_number = size(IMU_path_set,2)
    if path_number ~= PATH
        err='path number wrong line 65'
        return
    end
    foot_path_set={};
    raw_path_vs = {};
    path_sig_loc = {};
    total_sig_num =[];
    for path_num =1:path_number
        tmp_IMU_path = cell2mat(IMU_path_set(path_num));
        %sig amplitude
        sig_amp = zeros(1,path_number);
        for sig_num=1:size(tmp_IMU_path,2)
            tmp_sig = nx(tmp_IMU_path(sig_num)-100:tmp_IMU_path(sig_num)+20);
            sig_amp(sig_num) = max(tmp_sig);
        end
        
        % missing detection
        test1 = tmp_IMU_path(1:end-1);
        test2 = tmp_IMU_path(2:end);
        differ = test2 - test1;
        if size(differ,2) > 11
        differ = differ(1:11);
        end
        if max(differ) > 7000
            err='IMU signal detection wrong'
            return;
        end
        
        new_IMU_path = tmp_IMU_path;
        if size(new_IMU_path,2)<8
            err="can not detecte a available path"
            return
        end     
        

        %signal extract
        
        [sig_num1, tmp_footstep_set1, raw_path_vs1, path_sig_loc1] = new_IMU_path_vibration_signal_extract(vs1, filted_vs1, new_IMU_path,filted_bck1, blank1, signal_th(scenario, 1), nx);
        [sig_num2, tmp_footstep_set2, raw_path_vs2, path_sig_loc2] = new_IMU_path_vibration_signal_extract(vs2, filted_vs2, new_IMU_path,filted_bck2, blank2, signal_th(scenario, 2), nx);
        [sig_num3, tmp_footstep_set3, raw_path_vs3, path_sig_loc3] = new_IMU_path_vibration_signal_extract(vs3, filted_vs3, new_IMU_path,filted_bck3, blank3, signal_th(scenario, 3), nx);
        [sig_num4, tmp_footstep_set4, raw_path_vs4, path_sig_loc4] = new_IMU_path_vibration_signal_extract(vs4, filted_vs4, new_IMU_path,filted_bck4, blank4, signal_th(scenario, 4), nx);
        

        Path={{tmp_footstep_set1}; {tmp_footstep_set2}; {tmp_footstep_set3}; {tmp_footstep_set4}};
        current_raw_path_vs = {{raw_path_vs1}; {raw_path_vs2}; {raw_path_vs3}; {raw_path_vs4}};
        current_path_sig_loc = {{path_sig_loc1}; {path_sig_loc2}; {path_sig_loc3}; {path_sig_loc4}};
            
        foot_path_set(path_num) = {Path};     
        raw_path_vs(path_num) = {current_raw_path_vs};
        path_sig_loc(path_num) = {current_path_sig_loc};
        current_sig_num = [sig_num1; sig_num2; sig_num3; sig_num4];
        total_sig_num(:, path_num) = current_sig_num;
    end
    total_sig_num
    
    eval([char(obj_name(tmp_obj_num)), '_ftst = foot_path_set;'])
    eval([char(obj_name(tmp_obj_num)), '_bck = raw_bck;'])
    eval([char(obj_name(tmp_obj_num)), '_sig_loc = path_sig_loc;'])
    eval([char(obj_name(tmp_obj_num)), '_raw_vs = raw_path_vs;'])
    
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)),'_ftst'',''-append'');']);
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)), '_bck'',''-append'');']);
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)), '_sig_loc'',''-append'');']);
    eval(['save(file_na, ''', char(obj_name(tmp_obj_num)), '_raw_vs'',''-append'');']);
    %save(file_name,'BCK','foot_path_set', 'raw_bck', 'raw_path_vs', 'path_sig_loc');
end

end