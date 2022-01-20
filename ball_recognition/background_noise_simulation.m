clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
later_part ="_id_location.mat";
obj_name=["B1","B3","B4","B5"];
later_pa ="_ball_dataset.mat";

bck_start_stop_cell={
    {68970,78070},{68970,78070},{68970,78070},{68970,78070},{68970,78070};
    {68970,78070},{68970,78070},{68970,78070},{68970,78070},{1,12000};
    {68970,78070},{58970,68070},{68970,78070},{68970,78070},{68970,78070}; %
    {58970,68070},{68970,78070},{58970,68070},{58970,68070},{58970,68070}; %4
    {68970,78070},{68970,78070},{58970,68070},{58970,68070},{58970,68070}; %5
    {68970,78070},{5000,15000},{68970,78070},{68970,78070},{68970,78070}; %6
    {1,7000},{53000,59000},{72970,78070},{1,12000},{65970,75070}; %7
    {68970,78070},{68970,78070},{68970,78070},{68970,78070},{68970,78070}; %8
    {58970,68070},{58970,68070},{58970,68070},{58970,68070},{58970,68070}; %9
    {58970,68070},{68970,78070},{68970,78070},{68970,78070},{68970,78070}; %10
    {48970,58070},{68970,78070},{48970,58070},{58970,68070},{52970,58070}; %11
    };

for scenario = 10:11
    sc_count = scenario;
    sensor_num= 4;
    if scenario > 9
        sensor_num= 6;
    end

    dataset_path ='../mat_dataset';
    file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_pa)];
    load(file_name);
        
    for vib_type = 1:length(obj_name)
        for sensor =1:sensor_num
            eval(['tmp_sig_set =', char(obj_name(vib_type)), '_', num2str(sensor), ';']);

            bck_range = cell2mat(bck_start_stop_cell{scenario, vib_type});
            %eval(['bck_range = ', char(sig_name_set(vib_type)), '_bck_range;'])
            tmp_sig_set = tmp_sig_set - mean(tmp_sig_set);
            raw_bck = tmp_sig_set(bck_range( 1):bck_range( 2));
            h = histogram(raw_bck,21);
        end
    end
end