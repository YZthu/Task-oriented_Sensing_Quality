function [H, Nor_H] = signal_entropy(signal)
X = fft(signal,6500);
X = abs(X);
X = X(1:floor(size(X,2)/2));
S = X.^2;
P = S ./ sum(S);
H = -1* sum(P.*log(P)/log(2));
Nor_H = H/(log(size(P,2))/log(2));
end