clear all;
close all;
clc;


data_path ='..\decode_data\';
deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

later_pa ="_ball_dataset.mat";
sig_name_set =["B1", "B2", "B3", "B4", "B5"];
s1_th=[
    50,23,35,35,30;
    50,23,35,95,30;
    150,60,100,135,100;
    60,73,200,95,100; %4
    60,53,200,95,80; %5
    16,25,18.5,19,19; %6
    25,20,20,19,19; %7
    60,25,200,95,25; %8
    25,19,50,95,26; %9
    160,78,200,95,83; %10
    90,53,200,95,55; %11
    ];

s2_th=[
    20,13,10,10,19;
    20,10.5,50,50,19;
    120,40,100,100,79;
    60,50,200,95,100; %4
    60,30,200,95,40 %5
    9,9,9,9,9 %6
    30,20,40,40,25 %7
    60,13,200,95,25 %8
    20,11,50,55,15 %9
    60,36,200,95,35 %10
    60,50,200,95,41 %11
    ];
s3_th=[
    20,15,180,180,26;
    24,15,100,100,26;
    120,105,180,180,126;
    70,80,200,95,100; %4
    70,40,200,95,50; %5
    15,20,25,25,25; %6
    15,10,15,15,20; %7
    70,20,200,95,50; %8
    40,10,200,95,10; %9
    70,45,200,95,35; %10
    70,40,200,95,42; %11    
    ];
s4_th=[
    20,5,10,10,8;
    10,5,10,20,8;
    90,18,100,100,30;
    30,20,35,95,30; %4
    30,7.5,35,95,12; %5
    2,2,3,3,1.8; %6
    4,2,2.5,2.5,4; %7
    30,10,35,95,30; %8
    30,3,35,55,5; %9
    30,17,35,75,18; %10
    20,6.2,35,95,7.0; %11
    ];

s5_th=[
    20,5,10,10,8;
    10,5,10,20,8;
    90,18,100,100,30;
    30,20,35,95,30; %4
    30,7.5,35,95,12; %5
    2,2,3,3,1.8; %6
    4,2,2.5,2.5,4; %7
    30,10,35,95,30; %8
    30,3,35,55,5; %9
    15,3.7,35,35,3.4; %10
    15,4.2,25,35,4.3; %11
    ];

s6_th=[
    20,5,10,10,8;
    10,5,10,20,8;
    90,18,100,100,30;
    30,20,35,95,30; %4
    30,7.5,35,95,12; %5
    2,2,3,3,1.8; %6
    4,2,2.5,2.5,4; %7
    30,10,35,95,30; %8
    30,3,35,55,5; %9
    250,225,305,225,350; %10
    320,250,350,330,260; %11
    ];

detected_path_num_kind1 =[1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8;1,8;1,8;];
detected_path_num_kind2 =[1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8;1,8;1,8;];
detected_path_num_kind3 =[1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8; 1,8;1,8;1,8;];
detected_path_num_kind4 =[1,8; 1,8; 1,8; 1,8; 2,8; 1,8; 1,8; 1,8; 1,8; 1,8;1,8;1,8;];

bpFilt1 = designfilt('bandpassfir','FilterOrder',500, ...
     'CutoffFrequency1', 20,'CutoffFrequency2',400, ...
     'SampleRate',6500);

 bpFilt2 = designfilt('bandpassfir','FilterOrder',500, ...
     'CutoffFrequency1', 50,'CutoffFrequency2',300, ...
     'SampleRate',6500);
 bpFilt3 = designfilt('bandpassfir','FilterOrder',500, ...
     'CutoffFrequency1', 100,'CutoffFrequency2',200, ...
     'SampleRate',6500);
 bpFilt4 = designfilt('bandpassfir','FilterOrder',500, ...
     'CutoffFrequency1', 130,'CutoffFrequency2',180, ...
     'SampleRate',6500);

for scenario=1:11
    scenario
    mat_flag = 1;
    dataset_path ='../mat_dataset';
    file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_pa)];
    load(file_name);
    
    later_part = "_id_location.mat";
    save_filename = [ char(deployment_name(scenario)), char(later_part)];

    sensor_number = 4;
    if scenario > 9
        sensor_number = 6;
    end

    for sig_name_num =1:size(sig_name_set,2)
        eval(['detected_path_num = detected_path_num_kind1', ';']);
        
        for sensor_num=1:sensor_number
            
        eval(['Sig_threshold', num2str(sensor_num), ' = s', num2str(sensor_num), '_th;'])
        eval(['tmp_sig_set =', char(sig_name_set(sig_name_num)), '_', num2str(sensor_num), ';']);
        
        tmp_sig_set = tmp_sig_set - mean(tmp_sig_set);
        time_len = size(tmp_sig_set,2)/6500;
        
        eval(['sensor_data', num2str(sensor_num), ' = tmp_sig_set;']);
        end
        
        [signals1, sig_loc1] = partial_signal_extract(sensor_data1, 300, Sig_threshold1(scenario, sig_name_num));
        [signals2, sig_loc2] = partial_signal_extract(sensor_data2, 300, Sig_threshold2(scenario, sig_name_num));
        [signals3, sig_loc3] = partial_signal_extract(sensor_data3, 300, Sig_threshold3(scenario, sig_name_num));
        [signals4, sig_loc4] = partial_signal_extract(sensor_data4, 300, Sig_threshold4(scenario, sig_name_num));
    
        
        path_distance = 12000;

        path_set1 = path_detection(sig_loc1, path_distance, 5);
        path_set2 = path_detection(sig_loc2, path_distance, 5);
        path_set3 = path_detection(sig_loc3, path_distance, 5);
        path_set4 = path_detection(sig_loc4, path_distance, 5);  
 
        sensor1_path_start = cell2mat(path_set1(1));
        sensor2_path_start = cell2mat(path_set2(1));
        sensor3_path_stop = cell2mat(path_set3(end));
        sensor4_path_stop = cell2mat(path_set4(end));
        
        if scenario > 9
            [signals5, sig_loc5] = partial_signal_extract(sensor_data5, 300, Sig_threshold5(scenario, sig_name_num));
            [signals6, sig_loc6] = partial_signal_extract(sensor_data6, 300, Sig_threshold6(scenario, sig_name_num));
            
            path_set5 = path_detection(sig_loc5, path_distance, 5);  
            path_set6 = path_detection(sig_loc6, path_distance, 5);  
            
            sensor5_path_stop = cell2mat(path_set5(end));
            sensor6_path_stop = cell2mat(path_set6(end));
        end
        if scenario > 9
        re =[length(sig_loc1),length(sig_loc2),length(sig_loc3),length(sig_loc4), length(sig_loc5),...
            length(sig_loc6)]
        else
        re =[length(sig_loc1),length(sig_loc2),length(sig_loc3),length(sig_loc4)]
        end
        first_sig_loc = min([sensor1_path_start,sensor2_path_start]);
        first_sig_loc = max(1, first_sig_loc - 5000);
        last_sig_loc = max([sensor3_path_stop, sensor4_path_stop]);
        last_sig_loc = min(size(sensor_data1,2), last_sig_loc+ 5000);
    
        local_interval = linspace(first_sig_loc, last_sig_loc, detected_path_num(scenario,2)-detected_path_num(scenario,1)+2);
        path_number = detected_path_num(scenario,1):1:detected_path_num(scenario,2);
    %{
    new_path1 = path_plot(sensor_data1, sig_loc1, path_set1);
    sig_loc1 = cell2mat(new_path1);
    xx=zeros(1, size(sensor_data1,2));
    xx(round(local_interval)) = 400;
    hold on
    plot(xx, 'o');
    title(['path interval 1', sig_name_set(sig_name_num)])
    
    new_path2 = path_plot(sensor_data2, sig_loc2, path_set2);
    sig_loc2 = cell2mat(new_path2);
    xx=zeros(1, size(sensor_data2,2));
    xx(round(local_interval)) = 400;
    hold on
    plot(xx, 'o');
    title('path interval 2')
    
    new_path3 = path_plot(sensor_data3, sig_loc3, path_set3);
    sig_loc3 = cell2mat(new_path3);
    xx=zeros(1, size(sensor_data3,2));
    xx(round(local_interval)) = 400;
    hold on
    plot(xx, 'o');
    title('path interval 3')
    
    new_path4 = path_plot(sensor_data4, sig_loc4, path_set4);
    sig_loc4 = cell2mat(new_path4);
    xx=zeros(1, size(sensor_data4,2));
    xx(round(local_interval)) = 400;
    hold on
    plot(xx, 'o');
    title('path interval 4')
   
        
    if scenario > 9 
        new_path5 = path_plot(sensor_data5, sig_loc5, path_set5);
        new_path6 = path_plot(sensor_data6, sig_loc6, path_set6);
    end
     %}
    
    %dd =[new_path1; new_path2; new_path3; new_path4;]
    %save_path_set_to_file(deployment_name(scenario), 1, sig_name_set(sig_name_num), sensor_data1, new_path1);
    %save_path_set_to_file(deployment_name(scenario), 2, sig_name_set(sig_name_num), sensor_data2, new_path2);
    %save_path_set_to_file(deployment_name(scenario), 3, sig_name_set(sig_name_num), sensor_data3, new_path3);
    %save_path_set_to_file(deployment_name(scenario), 4, sig_name_set(sig_name_num), sensor_data4, new_path4);
    
    
    sig_path_th = 12000;
    test_path_set1 =cell(1,8);
    test_path_set2 =cell(1,8);
    test_path_set3 =cell(1,8);
    test_path_set4 =cell(1,8);
    test_path_set5 =cell(1,8);
    test_path_set6 =cell(1,8);
    
    for new_path_num=1:size(local_interval,2)-1
        tmp_path_start = local_interval(new_path_num);
        tmp_path_stop = local_interval(new_path_num+1);
        fin_start = max(1, tmp_path_start-5000);
        fin_stop = min(tmp_path_stop+5000, size(sensor_data1,2)- 2000);
        new_path_set1 = interval_based_path_detection(fin_start, fin_stop, sig_loc1,sig_path_th);
        test_path_set1(new_path_num) = {new_path_set1};
        new_path_set2 = interval_based_path_detection(fin_start, fin_stop, sig_loc2,sig_path_th);
        test_path_set2(new_path_num) = {new_path_set2};
        new_path_set3 = interval_based_path_detection(fin_start, fin_stop, sig_loc3,sig_path_th);
        test_path_set3(new_path_num) = {new_path_set3};
        new_path_set4 = interval_based_path_detection(fin_start, fin_stop, sig_loc4,sig_path_th);
        test_path_set4(new_path_num) = {new_path_set4};
        if scenario > 9
            new_path_set5 = interval_based_path_detection(fin_start, fin_stop, sig_loc5,sig_path_th);
            test_path_set5(new_path_num) = {new_path_set5};
            new_path_set6 = interval_based_path_detection(fin_start, fin_stop, sig_loc6,sig_path_th);
            test_path_set6(new_path_num) = {new_path_set6};
        end
    end

    %[new_path_set1, path_number1] = label_path_number(path_set1, local_interval, path_number);
    %[new_path_set2, path_number2] = label_path_number(path_set2, local_interval, path_number);
    %[new_path_set3, path_number3] = label_path_number(path_set3, local_interval, path_number);
    %[new_path_set4, path_number4] = label_path_number(path_set4, local_interval, path_number);
    
    
    dd=[test_path_set1;
    test_path_set2;
    test_path_set3;
    test_path_set4;]
    %save to file
       
    
    save_path_set_to_file(deployment_name(scenario), 1, sig_name_set(sig_name_num), sensor_data1, test_path_set1, '');
    save_path_set_to_file(deployment_name(scenario), 2, sig_name_set(sig_name_num), sensor_data2, test_path_set2, '');
    save_path_set_to_file(deployment_name(scenario), 3, sig_name_set(sig_name_num), sensor_data3, test_path_set3, '');
    save_path_set_to_file(deployment_name(scenario), 4, sig_name_set(sig_name_num), sensor_data4, test_path_set4, '');
    if scenario > 9
        save_path_set_to_file(deployment_name(scenario), 5, sig_name_set(sig_name_num), sensor_data5, test_path_set5, '');
        save_path_set_to_file(deployment_name(scenario), 6, sig_name_set(sig_name_num), sensor_data6, test_path_set6, '');
    end
    
    %bandpass simulation
    bp_name= ["bp1", "bp2", "bp3", "bp4"];
    for filter_type=1:4
        eval(['filt_n = bpFilt', num2str(filter_type), ';'])
        for sensor_n = 1:sensor_number
            eval(['tp_raw_data = sensor_data', num2str(sensor_n), ';'])
            eval(['tp_path_set = test_path_set', num2str(sensor_n), ';'])
            tmp_filt_data = filtfilt(filt_n, tp_raw_data);
            save_path_set_to_file(deployment_name(scenario), sensor_n, sig_name_set(sig_name_num), tmp_filt_data, tp_path_set, bp_name(filter_type));
        end
    end

    eval([ char(sig_name_set(sig_name_num)), '_interval = local_interval']);
    eval(['save(''', save_filename, ''', ''', char(sig_name_set(sig_name_num)), '_interval''', ',', '''-append'')' ]);
    for kk=1: sensor_number
        eval([ char(sig_name_set(sig_name_num)), '_', num2str(kk), '_sig_loc = test_path_set', num2str(kk),';']);
        eval(['save(''', save_filename, ''', ''', char(sig_name_set(sig_name_num)), '_', num2str(kk), '_sig_loc''', ',', '''-append'')' ]);
        %save raw signals
        eval([ char(sig_name_set(sig_name_num)), '_', num2str(kk), '_raw_sig = sensor_data', num2str(kk),';']);
        eval(['save(''', save_filename, ''', ''', char(sig_name_set(sig_name_num)), '_', num2str(kk), '_raw_sig''', ',', '''-append'')' ]);
    end
    end
end
    


