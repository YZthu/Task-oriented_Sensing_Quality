function entropy = power_spectral_entropy(sig1)
    
    fft_f = fft(sig1, 6500);
    half_re = fft_f(1:round(length(fft_f)/2));
    psd = abs(half_re).^2 / length(half_re);
    nor_psd = psd ./ sum(psd);
    entropy = -1* nor_psd* log2(nor_psd');
    
end