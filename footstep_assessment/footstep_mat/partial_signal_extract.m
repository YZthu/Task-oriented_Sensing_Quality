function [signals, sig_loc] = partial_signal_extract(raw_data, peak_number, ps, fil_flag)

%data_path = 'E:\dataset\vibration_system\';
%date = "2019-12-14";
%hour = '21';
%min = 19;
    bpFilt = designfilt('bandpassfir','FilterOrder',500, ...
         'CutoffFrequency1', 70,'CutoffFrequency2',500, ...
         'SampleRate',6500);
     
    
    if fil_flag
        fil_data = filtfilt(bpFilt, raw_data);
    else
        fil_data = raw_data;
    end

    [maxv,sig_loc]= findpeaks(fil_data,'minpeakdistance',2200,'NPeaks',peak_number, 'MinPeakHeight', ps);
    
    if size(maxv,2) ~= peak_number
        size(maxv,2) 
        eee='errorrrrrrr'
        
    end
    signals = [];
  
    %figure
    %plot(tmp_sig)
end

