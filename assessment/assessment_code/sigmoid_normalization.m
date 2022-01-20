function [nor_factor] = sigmoid_normalization(factor_M, upthreshold)

%{
downthreshold = [
    0, 0, 0, 0, 2100, 1100, 600;
    0, 0, 0, 0, 3100, 1900, 1200];
%}
nor_factor = [];
piece_nor_factor=[];
for fa = 1:size(factor_M,2)
    tmp_factor = factor_M(:,fa);
    low_band = upthreshold(1,fa);
    up_band = upthreshold(2,fa);
    %low band -> 0.1 -> -2.1972;
    %up band ->0.9 -> 2.1972
    %if up_band - low_band < 0.1
        %up_band = low_band + 0.05*(max(tmp_factor)- min(tmp_factor));
    %end
    tmp_x = [low_band, up_band];
    
    tmp_y = [-2.1972, 2.1972];
   % p1 = polyfit(tmp_x, tmp_y, 1);
    
    
    %sigmoid norm
    nor_fa =[];
        %sig_in = polyval(p1, tmp_factor);
        %linfunction
        af_fa = (2*2.1972 / (up_band - low_band))* (tmp_factor - low_band) - 2.1972;
        nor_fa = sigmoid(af_fa);

        
    nor_factor(:, fa) = nor_fa;
    
end

end

function val = sigmoid(input)

val =[];
for kk=1:length(input)
    tmp_in = input(kk);
    val(kk) = 1/ (1+ exp(-1*tmp_in));
end

%val = 1/ (1+ exp(-1*input));

end
