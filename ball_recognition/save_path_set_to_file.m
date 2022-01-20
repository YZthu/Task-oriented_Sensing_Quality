function save_path_set_to_file(sc_name, sensor_num, sig_name, raw_sig, path_set, name_append)

data_len = size(raw_sig,2);
sig_set=cell(1, 8);
fft_set = cell(1,8);
for path=1:8
    tmp_sig_loc_set = path_set{path};
    if size(tmp_sig_loc_set,2) < 1
        continue;
    end
    tmp_set =[];
    tmp_fft_set =[];
    sig_ent=[];
    for sig_num=1:size(tmp_sig_loc_set,2)
        
        tmp_sig_loc = tmp_sig_loc_set(sig_num);
        if tmp_sig_loc -200 < 1 | tmp_sig_loc + 800>data_len
            continue;
        end
        
        tmp_sig = raw_sig(tmp_sig_loc-200: tmp_sig_loc+800-1);
        tmp_set = [tmp_set; tmp_sig];
        [tmp_sig_ent, nor_e] = signal_entropy(tmp_sig);
        sig_ent = [sig_ent, tmp_sig_ent];
        %FFT
        nor_sig = tmp_sig ./ sqrt(sum(tmp_sig.^2));
        fft_sig = fft(tmp_sig);
        fft_sig = abs(fft_sig);
        fft_sig = fft_sig(1: floor(size(fft_sig,2)/2));
        tmp_fft_set =[tmp_fft_set; fft_sig];
    end
    
    sig_ent;
    %%delete some wrong signal
    if size(sig_ent,2) < 1
        continue
    end
    mean_ent = mean(sig_ent);
    std_ent = std(sig_ent);
    for ent_num=size(sig_ent,2):-1:1
        if (abs(sig_ent(ent_num) - mean_ent) > std_ent) & abs(sig_ent(ent_num) - mean_ent)> 1
            d=tmp_set;
            %tmp_set(ent_num,:) =[];
            %tmp_fft_set(ent_num,:) =[];
        end
    end
    
    sig_set(path) = {tmp_set};
    fft_set(path) = {tmp_fft_set};
end
   
eval([char(sig_name), '_', num2str(sensor_num), char(name_append), '_set = sig_set;']);
%save mat
later_part ="_id_location.mat";
file_name = [char(sc_name), char(later_part)];
if ~exist(file_name, 'file')
    eval(['save(''', file_name, ''', ''', char(sig_name), '_', num2str(sensor_num), char(name_append), '_set'')' ]);
else
   eval(['save(''', file_name, ''', ''', char(sig_name), '_', num2str(sensor_num), char(name_append), '_set''', ',', '''-append'')' ]);
end

%save txt
%{
txt_name = ['.\location_txt\', char(sc_name), '_', char(sig_name), '_', num2str(sensor_num), '_set', '.txt']
f_w = fopen(txt_name, 'w');
for path_number=1:8
    tmp_set = fft_set{path_number};
    str=['*', num2str(path_number), '#'];
    fprintf(f_w, str);
    fprintf(f_w,'\n');
    if size(tmp_set,2) > 0
        
        for kk=1:size(tmp_set,1)
            tmp_fft_sig = tmp_set(kk,:);
            fprintf(f_w,'%g ',tmp_fft_sig);
            fprintf(f_w,'\n');
        end
    end
end
fclose(f_w);
%}
end