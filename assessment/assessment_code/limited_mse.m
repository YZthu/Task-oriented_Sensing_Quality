function mse= limited_mse(ssq, acc)

    lim_ssq = ssq;
    tmp_loc = find(ssq>1);
    %lim_ssq(tmp_loc)=1;
    tmp_loc = find(ssq<0);
    %lim_ssq(tmp_loc)=0;
    % train ssq
        
    mse = (lim_ssq - acc).^2;
end