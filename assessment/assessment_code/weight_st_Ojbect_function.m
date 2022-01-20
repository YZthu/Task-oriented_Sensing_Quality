function re=weight_st_Ojbect_function(x, factor_m, train_acc)
low_band = x(1:size(factor_m,2))';
up_band = x(size(factor_m,2)+1: 2*size(factor_m,2))';
weight = x(2*size(factor_m,2)+1:end);

upthreshold =[low_band; up_band];
nor_factor = sigmoid_normalization(factor_m, upthreshold);
final_fa = mean(nor_factor,2);
add_offset_factor = [final_fa, ones(size(nor_factor,1),1)];
SSQ = add_offset_factor*weight;

% add the L2 regularization
lam = 0.1;
one_ve = ones(1, length(weight))*abs(weight);
re= mean((SSQ'- train_acc).^2) + lam*one_ve /(2*size(factor_m,1));


end