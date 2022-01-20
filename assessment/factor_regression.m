function f=factor_regression(x, factor_m, train_acc)

SSQ = factor_m*x;
lam = 0;
% scale 1/10;
f= mean((SSQ'- train_acc).^2) + lam*sum(abs(x))/(2*size(factor_m,1));
sum((SSQ'- train_acc).^2);
sum(abs(x));
% add the L0 or L1 regularization


end