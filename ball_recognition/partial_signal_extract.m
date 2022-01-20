function [signals, sig_loc] = partial_signal_extract(raw_data, peak_number, ps)

%data_path = 'E:\dataset\vibration_system\';
%date = "2019-12-14";
%hour = '21';
%min = 19;
    bpFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 70,'CutoffFrequency2',500, ...
         'SampleRate',6500);
     
    fil_data = filtfilt(bpFilt, raw_data);
    %fil_data = wiener2(raw_data, 3000);
    

    [maxv,sig_loc]= findpeaks(fil_data,'minpeakdistance',2000,'NPeaks',peak_number, 'MinPeakHeight', ps);
    
    if size(maxv,2) ~= peak_number
        size(maxv,2) 
        eee='errorrrrrrr'
        
    end
    signals = [];
    for kk=1:size(maxv,2)
        tmp_l = sig_loc(kk);      
        if tmp_l +500 > size(raw_data,2) | tmp_l- 100 < 1
            continue;
        end
        tmp_sig = raw_data(tmp_l-100:tmp_l + 500);
        
        signals = [signals; tmp_sig];
    end
    %{
        figure
    plot(fil_data)
    hold on
    plot(sig_loc, ps, 'o')
    title('filted sig')
    %}

end

