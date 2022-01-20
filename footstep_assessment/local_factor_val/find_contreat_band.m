function bandwidth = find_contreat_band(signal, energy_th)
%energy_th = 0.9;
X = fft(signal,6500);
X = abs(X);
X = X(1:floor(size(X,2)/2));
S = X.^2;
P = S ./ sum(S);
CPF=[];
for k=1:size(P,2)
    CPF(k) = sum(P(1:k));
end

stop_band = [];
energy_p =[];
for k=1:size(P,2)
    if CPF(k)> 1- energy_th
        break;
    end
    target_p = CPF(k)+ energy_th;
    [val, loc] = min(abs(CPF-target_p));
    real_gap = CPF(loc)- CPF(k);
    if abs(real_gap - energy_th)>0.01
        continue;
    end
    stop_band = [stop_band, loc-k];
end
if size(stop_band,2) <1
    energy_p =[];
for k=1:size(P,2)
    if CPF(k)> 1- energy_th
        break;
    end
    target_p = CPF(k)+ energy_th;
    [val, loc] = min(abs(CPF-target_p));
    real_gap = CPF(loc)- CPF(k);
    if abs(real_gap - energy_th)>0.03
        continue;
    end
    stop_band = [stop_band, loc-k];
end
end
if size(stop_band,2) <1
    stop_band=1;
end
bandwidth = min(stop_band);
end