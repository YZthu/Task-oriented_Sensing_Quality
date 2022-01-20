clear;
close all;
clc;

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];
later_part ="_id_location.mat";
obj_name=["B1","B3","B4","B5"];

bandpass_bandwidth=[1000, 500, 100,50, 20];
     
for scenario = [1:11]
    file_nam = ['./',char(deployment_name(scenario)), char(later_part)];
    load(file_nam);

    
    sensor_number=4;
    if scenario > 9
        sensor_number = 6;
    end
    for sen=1:sensor_number
        if sen ==1 | sen ==2
            select_path = 1:5;
        else
            select_path = 4:8;
        end
        
        if scenario >9
            if sen ==1 |sen ==2 | sen ==5 |sen ==6
                select_path=3:7;
            end
        end

        %vote the central frequency
        central_frequency=[];
        for tmp_obj_num=1:length(obj_name)
            eval(['raw_signal_set = ', char(obj_name(tmp_obj_num)),'_', num2str(sen), '_set;'])
            each_kind_central_fre=NaN(1, length(raw_signal_set));
            for path_n = 1:length(raw_signal_set)
                tmp_set = raw_signal_set{path_n};
                if size(tmp_set,1)<1
                    continue;
                end
                all_fft =[];
                for kk=1:size(tmp_set,1)
                    tmp_signal = tmp_set(kk,:);
                    if isnan(tmp_signal(1))
                        
                        continue;
                    end
                    nor_sig = tmp_signal ./ sqrt(sum(tmp_signal.^2));
                    fft_sig = fft(nor_sig, 6500);
                    half_fft = abs(fft_sig(1:3250));
                    %figure
                    %plot(half_fft);
                    [~, cent_f] = max(half_fft);
                    all_fft = [all_fft; cent_f];
                end
                
                mean_f = nanmean(all_fft);
                std_f = std(all_fft);
                less_flag = all_fft < mean_f - std_f;
                larger_flag = all_fft > mean_f + std_f;
                if length(less_flag) > 0
                    all_fft(less_flag) = NaN;
                end
                if length(larger_flag) > 0
                    all_fft(larger_flag) = NaN;
                end
                tmp_cent_f = nanmean(all_fft);
                
                each_kind_central_fre(path_n) = tmp_cent_f;
            end
            central_frequency = [central_frequency; each_kind_central_fre];
        end
            
        final_cent_fre = nanmean(nanmean(central_frequency,1));
        eval([char(deployment_name(scenario)), '_', num2str(sen), ' = central_frequency;'])
        sav_filename= 'cent_freq.mat';
        if exist(sav_filename)
            eval(['save(''', sav_filename, ''', ''', char(deployment_name(scenario)), '_', num2str(sen), ''', ''-append'')' ]);
            
        else
            eval(['save(''', sav_filename, ''', ''', char(deployment_name(scenario)), '_', num2str(sen), ''')' ]);
        end
    
        bp_name= ["bp1", "bp2", "bp3", "bp4", "bp5"];
        for filter_type=1:5
            filter_bw = bandpass_bandwidth(filter_type);
            
        sig_length=[];
        for path_n=1:length(select_path)
            path = select_path(path_n);
            cent_fre = final_cent_fre;
            start_fre = round( cent_fre - filter_bw/2 +1);
            stop_fre = round( cent_fre + filter_bw/2);
            if start_fre < 1
                start_fre =1;
            end
            if stop_fre > 3250
                stop_fre = 3250;
            end
                
            bpfilter = designfilt('bandpassfir','FilterOrder',500, ...
             'CutoffFrequency1', start_fre,'CutoffFrequency2',stop_fre, ...
             'SampleRate',6500);
            csv_name = ['./ball_1345_3c_csv/', char(deployment_name(scenario)),'_', char(bp_name(filter_type)), '_', num2str(sen),'_',num2str(path_n) ,'.csv'];
            all_sig =[];
            all_location=[];
            all_class=[];
            
            for tmp_obj_num = 1:length(obj_name)
                eval(['ttt_raw_sig = ', char(obj_name(tmp_obj_num)),'_', num2str(sen), '_raw_sig;'])
                eval(['ttt_sig_loc = ', char(obj_name(tmp_obj_num)),'_', num2str(sen), '_sig_loc;'])
                tmp_sig_loc_set = ttt_sig_loc{path};
                
                tmp_filt_data = filtfilt(bpfilter, ttt_raw_sig);
                    
                if size(tmp_sig_loc_set,2) < 1
                    continue;
                end
                tmp_set =[];
                tmp_fft_set =[];
                sig_ent=[];
                for sig_num=1:size(tmp_sig_loc_set,2)

                    tmp_sig_loc = tmp_sig_loc_set(sig_num);
                    if (tmp_sig_loc -200 < 1) || (tmp_sig_loc + 800>length(tmp_filt_data))
                        continue;
                    end
                    tmp_sig = tmp_filt_data(tmp_sig_loc-200: tmp_sig_loc+800-1);
                    tmp_set = [tmp_set; tmp_sig];
                end
        %{
                eval(['tmp_cell_set = ', char(obj_name(tmp_obj_num)),'_', num2str(sen), char(bp_name(filter_type)), '_set;'])
                tmp_set = tmp_cell_set{path};
          %}      
                if size(tmp_set,1)<1
                    sig_length = [sig_length, 0];
                    continue;
                end

                for kk=1:size(tmp_set,1)
                    tmp_signal = tmp_set(kk,:);
                    if isnan(tmp_signal(1))
                        continue;
                    end
                    %fft
                    nor_sig = tmp_signal ./ sqrt(sum(tmp_signal.^2));
                    fft_sig = fft(nor_sig, 6500);
                    half_fft = abs(fft_sig(1:3250));
                    all_sig = [all_sig; half_fft];
                    all_class =[all_class, obj_name(tmp_obj_num)];
                    
                        all_location =[all_location, path_n];
                    if kk > 9
                        break;
                    end
                end
                sig_length = [sig_length, kk];
            end
            %re=table(all_class', all_location', all_sig);
            re=table(all_class', all_sig);
            writetable(re,csv_name);
        end
        end

    end
    
end