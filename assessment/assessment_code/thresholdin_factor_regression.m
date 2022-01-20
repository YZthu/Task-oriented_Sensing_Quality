function f=thresholdin_factor_regression(x, factor_m, train_acc)
low_band = x(1:size(factor_m,2));
up_band = x(size(factor_m,2)+1: 2*size(factor_m,2));
wei = x(2*size(factor_m,2)+1:end);

upthreshold =[low_band'; up_band'];
nor_factor = sigmoid_normalization(factor_m, upthreshold);
add_offset_factor = [nor_factor, ones(size(nor_factor,1),1)];
SSQ = add_offset_factor*wei;
lam = 0.1;
% scale 1/10;
f= sum((SSQ'- train_acc).^2);% + lam*sum(abs(x));
sum((SSQ'- train_acc).^2);
sum(abs(x));
% add the L0 or L1 regularization


end