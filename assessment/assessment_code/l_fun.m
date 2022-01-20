function f=l_fun(x, factor_m, W_c)

factor_number = size(factor_m,2);

%{
fact_n = size(factor_m, 2);

B =[];
for kk=1:size(factor_m,1)
    B(kk,:) = x(fact_n+1:end);
end

SSQ = (B+ factor_m)*x(1:fact_n);
%}
SSQ = factor_m*x;
f=0;
for kk=1:size(factor_m,1)-1
    for jj=kk+1:size(factor_m, 1)
        tmp_l = W_c(kk,jj)* log(exp(SSQ(kk))/ (exp(SSQ(kk)) + exp(SSQ(jj))) ) + W_c(jj,kk)* log(exp(SSQ(jj))/ (exp(SSQ(kk)) + exp(SSQ(jj))) );
        f = f - tmp_l;
    end
end
f
end