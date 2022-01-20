function new_path_set = interval_based_path_detection(start_p, stop_p, sig_loc_set, sig_path_th)

state = 0;
sig_start = 0;
sig_stop = 0;
for j=1:size(sig_loc_set,2)
    tmp_l = sig_loc_set(j);
    if (tmp_l >= start_p) && (state ==0) % ??
        sig_start = j;
        state =1;
    end
    if (tmp_l > stop_p) && (state ==1)
        sig_stop = j;
        break;
    end
end

if sig_stop ==0 && state ==1
    sig_stop = size(sig_loc_set,2);
end

if sig_start == 0 | sig_stop ==0
    new_path_set =[];
    return
end

sig_set_con = sig_loc_set(sig_start:sig_stop);
tmp_path = path_detection(sig_set_con,sig_path_th, 4);
tmp_path
if size(tmp_path,2) >1
    new_path_set =[]
    set_len =[];
    for kk=1:size(tmp_path,2)
        tmp_set = tmp_path{kk};
        set_len(kk) = size(tmp_set,2);
    end
    [v, l] = max(set_len);
    if v > 7
        new_path_set = tmp_path{l};
    else
        new_path_set = [tmp_path{1}, tmp_path{2}];
    end
        
else
    if size(tmp_path,2) ==1
        new_path_set = tmp_path{1};
    else
        new_path_set =[];
    end
end
end