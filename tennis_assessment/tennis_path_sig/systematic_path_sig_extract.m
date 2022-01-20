clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

dataset_path ='../../mat_dataset';


bck_loc =[259300,269000; %1
    195900, 211700;
    195900, 211700; %3
    185900, 201700; %4
    195900, 211700; %5
    185900, 200000; %6
    185900, 191700; %7
    195900, 211700; %8
    185900, 201700; %9
    185900, 201700; %10
    308100, 311700; %11
];

sc =[11]
for scenario =  sc
    if scenario <4
        later_part ="_corr_tennis_dataset.mat";
    else
        later_part ="_tennis_dataset.mat";
    end
file_name = [char(dataset_path), '/',char(deployment_name(scenario)), char(later_part)];
load(file_name);
sen_number =4;
if scenario > 9
    sen_number =6;
end

for sensor=1:sen_number
    if scenario < 4
        eval(['raw_sig = corr_raw_', num2str(sensor), ';'])
    else
        eval(['raw_sig = raw_', num2str(sensor), ';'])
    end
    %eval(['raw_ts = ts', num2str(sensor), ';'])
    raw_ts = NaN;
    raw_sig = raw_sig - mean(raw_sig);
    %{
    figure
    plot(raw_sig)
    title(num2str(sensor))
    %}
    
    tmp_bck_loc = bck_loc(scenario,:);
    [BCK, raw_BCK, path_sig_set, path_sig_ts,path_sig_wv, path_sig_loc_set] = tennis_path_based_signal_extraction(sensor, scenario, raw_sig,tmp_bck_loc, raw_ts);
    
    figure
    plot(raw_sig)
    hold on
    sig_loc = [];
    for d =1:length(path_sig_loc_set)
        tmp = cell2mat(path_sig_loc_set(d));
        sig_loc = [sig_loc, tmp];
    end
    plot(sig_loc, 0.5*max(raw_sig), '*')
    
    if length(path_sig_set) ~= 24
        err='e';
    end
    for kk=1:size(path_sig_set,2)
        tmp_set = path_sig_set{kk};
        if size(tmp_set,1) == 0
            err='path sig detection error'
            break;
        end
        
        %{
        for tttt =1:size(tmp_set,1)
            tmp_sig = tmp_set(tttt,:);
        figure
        plot(tmp_sig);
        title(num2str(kk))
        end
        %}
    end
    %change the path set sequence
    new_path_set ={};
    coun=0;
    for path_n=1:3
        for loc_n =1:8
            tmp_loc = 3*(loc_n-1)+path_n;
            coun = coun +1;
            new_path_set(coun) = path_sig_set(tmp_loc);
        end
    end
    eval(['bck', num2str(sensor), ' = BCK;'])
    eval(['raw_bck', num2str(sensor), ' = raw_BCK;'])
    eval(['path_sig_set', num2str(sensor), '= new_path_set;'])
    %eval(['path_sig_ts', num2str(sensor), '= path_sig_ts;'])
    eval(['path_sig_wv', num2str(sensor), '= path_sig_wv;'])
    
    new_path_set
    %{
    path_set = path_sig_set;
    for jj=1:3
    tmp_sig = zeros(1,8*10*1000);
    for kk =1:8
        path_sig = path_set{(jj-1)*8 + kk};
        ttt_sig = reshape(path_sig', 1, size(path_sig,1)*size(path_sig, 2));
        tmp_sig((kk-1)*10000 +1:(kk-1)*10000 +size(ttt_sig,2)) = ttt_sig;
    end
    
    figure
    plot(tmp_sig)
    title(num2str(jj));
    
    end
    %}

end

%result
later_pa ="_tennis_path_sig_SE.mat";
file_name = [char(deployment_name(scenario)), char(later_pa)];
save(file_name,'bck1','bck2','bck3','bck4','raw_bck1','raw_bck2','raw_bck3',...
'raw_bck4', 'path_sig_set1', 'path_sig_set2', 'path_sig_set3', 'path_sig_set4',...
'path_sig_wv1', 'path_sig_wv2', 'path_sig_wv3', 'path_sig_wv4');
if scenario > 9
    save(file_name,'bck5','bck6','raw_bck5','raw_bck6',...
'path_sig_set5', 'path_sig_set6',...
'path_sig_wv5', 'path_sig_wv6', '-append');
end
end