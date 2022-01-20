function local_factor_array = local_factor_calculate_from_path_sig(scenario, sensor, path_set, distance_set,bck)

e_A = [];
e_B = [];
i_A = [];
i_B = [];
R_e = [];
R_i = [];

H = [];
%for path_num =1:size(path_set,2)
all_SNR=[];
for path_num =1:size(path_set,2)
    tmp_sig_set = cell2mat(path_set(path_num));
    SNR =[];
    for ind = 1:size(tmp_sig_set,1)
        tmp_sig = tmp_sig_set(ind,:);
        tmp_snr = 10*log(mean(tmp_sig.^2)/bck)/log(10);
        SNR = [SNR, tmp_snr];
    end
    rank_SNR = sort(SNR);
    new_SNR = SNR(2:end-1);
    all_SNR = [all_SNR, mean(new_SNR)];
end


%%
tmp_SNR=reshape(all_SNR, size(all_SNR,2)/3,3)';
for path_num=1:3
    SNR = tmp_SNR(path_num,:);
    
    switch sensor
        case 1
            loc = 3;
            half_p1 = flip(SNR(1:loc));
            half_p2 = SNR(loc:end);
        case 2
            loc = 3;
            half_p1 = flip(SNR(1:loc));
            half_p2 = SNR(loc:end);
        case 3
            loc = 6;
            half_p2 = flip(SNR(1:loc));
            half_p1 = SNR(loc:end);
        case 4
            loc = 6;
            half_p2 = flip(SNR(1:loc));
            half_p1 = SNR(loc:end);
    end
    
    if scenario ==10
        switch sensor
            case 1
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
            case 2
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
            case 3
                loc = 6;
                half_p2 = flip(SNR(1:loc));
                half_p1 = SNR(loc:end);
            case 4
                loc = 6;
                half_p2 = flip(SNR(1:loc));
                half_p1 = SNR(loc:end);
            case 5
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
            case 6
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
        end
    end
    if scenario ==10 | scenario ==11
        switch sensor
            case 1
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
            case 2
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
            case 3
                loc = 6;
                half_p2 = flip(SNR(1:loc));
                half_p1 = SNR(loc:end);
            case 4
                loc = 6;
                half_p2 = flip(SNR(1:loc));
                half_p1 = SNR(loc:end);
            case 5
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
            case 6
                loc = 5;
                half_p1 = flip(SNR(1:loc));
                half_p2 = SNR(loc:end);
        end
    end
    %half_p1 is exterior
    %half_p2 is interior
    if size(half_p2,2)>3
        half_p2 = half_p2(1:3);
    end
    
    distance = distance_set(path_num)  % different have different config
    x1 =zeros(1, size(half_p1,2));
    x2 = zeros(1, size(half_p2,2));
    
    trend_flag = 1;
    pre = half_p1(1);
    x1(1) =  distance;
    for coun=2:size(half_p1,2)
        x1(coun) = sqrt(distance^2 + (2*(coun-1))^2);
        if half_p1(coun) >= pre
            trend_flag = 0;
            
        else
            pre = half_p1(coun);
        end
    end
    
    pre = half_p2(1)
    x2(1) =  distance;
    for coun=2:size(half_p2,2)
        x2(coun) = sqrt(distance^2 + (2*(coun-1))^2);
        if half_p2(coun) >= pre
            trend_flag = 0;
            
        else
            pre= half_p2(coun);
        end
    end
    
    if trend_flag == 0
        %continue;
    end

    %fit
    ab1 = polyfit(x1, half_p1+ log(x1/2),1);
    ab2 = polyfit(x2, half_p2 + log(x2/2),1);
    
    if size(half_p1,2)>2
        tpc = corrcoef(x1, half_p1);
        R1 = abs(tpc(2,1));
    else
        R1 = 0;
    end
    if size(half_p2,2)>2
        tpc = corrcoef(x2, half_p2);
        R2 = abs(tpc(2,1));
    else
        R2 = 0;
    end
    
    
    %H 
    coun =  min(size(half_p1,2), size(half_p2,2));
    tmp_H =[];
    for sample =2:coun
        sig1_loc_set = cell2mat(path_set((path_num-1)*size(tmp_SNR,2) + loc - (sample-1)));
        sig2_loc_set = cell2mat(path_set((path_num-1)*size(tmp_SNR,2) + loc + (sample-1)));
        if size(sig2_loc_set,2)< 10 | size(sig1_loc_set,2)< 10
            continue;
        end
        for sig1_number=1:size(sig1_loc_set,1)
            sig1 = sig1_loc_set(sig1_number,:);
            for sig2_num =1:size(sig2_loc_set,1)
                sig2 = sig2_loc_set(sig2_num,:);
        
                sig11 = sig1./sqrt(sum(sig1.^2));
                sig22 = sig2./sqrt(sum(sig2.^2));
                
                h = max(xcorr(sig11, sig22));
                tmp_H = [tmp_H, h];
            end
        end
    end
    H = [H, max(tmp_H)];
    
    R_e = [R_e, R1];
    R_i = [R_i, R2];
    
    
    if R1 > 0.7
        e_A = [e_A, ab1(1)];
        e_B = [e_B, ab1(2)];
    end
    if R2 > 0.7
        i_A = [i_A, ab2(1)];    
        i_B = [i_B, ab2(2)];
    end
    
    %{
    figure
    plot(SNR, 'LineWidth',3)
    xlabel('locations')
    ylabel('SNR (dB)')
    title([num2str(sensor), '  ex ', num2str(R1), ' in ', num2str(R2)]);
    
    figure
    plot(SNR)
    title([num2str(sensor), ' ', num2str(R1),'   ', num2str(R2)]);
    figure
    plot(half_p1)
    title('ext')
    figure
    plot(half_p2)
    title('int')
    %}


   
end


fin_e_A = mean(e_A)
fin_e_B = mean(e_B)
fin_i_A = mean(i_A)
fin_i_B = mean(i_B)
fin_H = max(H)

local_factor_array=[fin_e_A,fin_e_B, fin_i_A, fin_i_B, fin_H];

end