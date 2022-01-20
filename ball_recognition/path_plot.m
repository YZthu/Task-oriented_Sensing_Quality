function new_path = path_plot(tmp_sig1, sig_loc, path_set)
new_path={};
for path_num =1:size(path_set,2)
    tmp_path = cell2mat(path_set(path_num));
    if size(tmp_path,2) <6
        new_path(path_num) = path_set(path_num);
        continue;
    end
    amp =[];
    for ind = 1:size(tmp_path,2)
        if tmp_path(ind)-10 < 1 | tmp_path(ind)+50 > size(tmp_sig1,2)
            continue;
        end
        tmp_sig = tmp_sig1(tmp_path(ind)-10: tmp_path(ind)+50);
        tmp_amp = max(tmp_sig);
        amp = [amp, tmp_amp];
    end
    [~, id] = sort(abs(amp-mean(amp)),'ascend');
    if size(id,2) > 10
    keep_loc = id(1:10);
    else
        keep_loc = id;
    end
    
    new_loc = tmp_path(keep_loc);
    new_path(path_num) = {new_loc};
end

path_set = new_path;
figure
plot(tmp_sig1)
hold on
tmp_ss = zeros(1, size(tmp_sig1,2));
tmp_ss(cell2mat(path_set)) = 200;
plot(tmp_ss, '*');
tmp_ss = zeros(1, size(tmp_sig1,2));
tmp_ss(sig_loc) = 100;
plot(tmp_ss, 'o');
end