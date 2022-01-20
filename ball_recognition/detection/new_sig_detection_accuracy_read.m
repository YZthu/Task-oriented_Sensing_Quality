function [F1_score, ture_positive_rate] = new_sig_detection_accuracy_read()

deployment_name =["Garage", "Aisle_rug", "Bridge",...
    "Hall", "Aisle", "Livingroom_rug","Livingroom_base","Garage_k","Outdoor",...
    "Lab_beam", "Aisle_beam"];

load(['new_detection_rate.mat'])
%support_sc = [1,2,3,6,7,8,9,10,11,12];
ture_positive_rate =[];
for tmp_sc = 1:11
    eval(['tmp_sc_result = ', char(deployment_name(tmp_sc)), '_tp;'])
    ture_positive_rate =[ture_positive_rate, tmp_sc_result];
end

F1_score =[];
for tmp_sc = 1:11
    eval(['tmp_sc_result = ', char(deployment_name(tmp_sc)), '_f1;'])
    F1_score =[F1_score, tmp_sc_result];
end

end