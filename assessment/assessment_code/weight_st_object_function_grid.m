function grid = weight_st_object_function_grid(x, factor_M, train_acc)
low_bound_in = x(1:size(factor_M,2))';
up_bound_in = x(size(factor_M,2)+1: 2*size(factor_M,2))';
weight = x(2*size(factor_M,2)+1:end);


upthreshold =[low_bound_in; up_bound_in];
nor_factor = sigmoid_normalization(factor_M, upthreshold);
final_fa = mean(nor_factor,2);
add_offset_factor = [final_fa, ones(size(nor_factor,1),1)];
TSQ = add_offset_factor*weight;
%weight gradient
weight_gd=[];
lam = 0.1;
for i=1:size(add_offset_factor,2) % factor number
    w_gr=0;
    for k=1:size(add_offset_factor,1) % deployment number
        w_gr = w_gr + 2*(TSQ(k) - train_acc(k))* add_offset_factor(k,i);
    end
    %weight_gd(i) = w_gr + (lam/size(factor_M,1))* weight(i);
    if weight(i)> 0
        weight_gd(i) = w_gr + (lam/size(factor_M,1))* 1;
    else
        weight_gd(i) = w_gr + (lam/size(factor_M,1))* -1;
    end
end

% up bound grid

Sig1 = -2.1972;
Sig9 = 2.1972;
raw_offset_factor = [factor_M, ones(size(factor_M,1),1)];

upbound_gd=[];
for i=1:length(up_bound_in)
    tmp_gd =0;
    for k=1:size(add_offset_factor,1)
        tmp_gd = [tmp_gd, 2*(TSQ(k) - train_acc(k))* (weight(1)/5)* nor_factor(k,i)*(1-nor_factor(k,i))*...
            -1*((Sig9-Sig1)/(up_bound_in(i) - low_bound_in(i))^2)* (factor_M(k,i)-low_bound_in(i))];
    end
    upbound_gd(i)= nansum(tmp_gd);%+ (lam/size(factor_M,1))* up_bound_in(i);
end
lowbound_gd=[];
for i=1:length(up_bound_in)
    tmp_gd =0;
    for k=1:size(add_offset_factor,1)
        tmp_gd = [tmp_gd, 2*(TSQ(k) - train_acc(k))* (weight(1)/5)* nor_factor(k,i)*(1-nor_factor(k,i))*...
            1*((Sig9-Sig1)/(up_bound_in(i) - low_bound_in(i))^2)* (factor_M(k,i)-up_bound_in(i))];
    end
    lowbound_gd(i)= nansum(tmp_gd);%+(lam/size(factor_M,1))* low_bound_in(i);
end
grid = [lowbound_gd'; upbound_gd'; weight_gd'];
end


function val = sigmoid(input)
val =[];
for kk=1:length(input)
    tmp_in = input(kk);
    val(kk) = 1/ (1+ exp(-1*tmp_in));
end

end