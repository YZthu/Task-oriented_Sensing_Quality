function [path_sig_set] = tennis_path_detection( all_sig_loc, distance_th, path_num_th)

sig_num = size(all_sig_loc, 2);
path_sig_set={};

    class ={};
    tmp_subset = {};
 for kk=1:sig_num
     
     tmp_loc = all_sig_loc(kk);
     class_num = size(class,2);
     if class_num == 0
         class(1) = {tmp_loc};
         continue;
     else
         all_cc =[];
         for ii=1:class_num
             tmp_class_loc = cell2mat(class(ii));
             loc_err = abs(tmp_class_loc - tmp_loc);
             min_val = min(loc_err);
             all_cc = [all_cc, min_val];
         end
         [value, ind] = min(all_cc);
         
         if value <= distance_th
             old_class = cell2mat(class(ind));
             new_class = [old_class, tmp_loc];
             class(ind) = {new_class};
         else
             class_num = size(class,2);
             class(class_num+1) = {tmp_loc};
         end
     end
 end
 
 count = 0;
 for kk=1:size(class, 2)
     tmp_set = cell2mat(class(kk));
     set_size = size(tmp_set, 2);
     if set_size >= path_num_th
         count = count +1;
         path_sig_set(count) = class(kk);
     end
 end
end