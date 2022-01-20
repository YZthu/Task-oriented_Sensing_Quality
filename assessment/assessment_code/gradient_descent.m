function solve = gradient_descent(low_initial, up_initial, w0, training_factor, train_acc,full_test_Met, test_acc)


low_xk = low_initial;
up_xk = up_initial;
w_xk = w0;
tol_optgap = 1.0e-12;
tol_gnorm = 1.0e-12;
xk = [low_xk, up_xk, w_xk]';
obe_loss=[];
count_fun = 0;
alpha_val=[];
test_loss=[];
%tmp_fun =@(x)adam_jbect_function(x, training_factor, train_acc);

solution_x =[];
for iteration=1:200
    grad = object_function_grid(xk, training_factor, train_acc);
    % find the step length
    alpha =1;
    f0 =Ojbect_function(xk, training_factor, train_acc);
    g0 = grad';
    
    pk = -1*grad;
    alpha = 0.002;
    
    %[xk1, fk1, exitflag, output] = fmin_adam(tmp_fun, xk, alpha);
    %if exitflag >2
        xk1 = xk + alpha * pk;
        fk1 = Ojbect_function(xk1, training_factor, train_acc);
    %end
    solution_x(:,iteration) = xk1;
    % repeat until the Armijo condition meets
    rho = 1/2;
    c = 1e-2;
    c2= 0.1;
    %{
    while 1
      count_fun = count_fun +1;
      xk1 = xk + alpha * pk;
      fk1 = Ojbect_function(xk1, training_factor, train_acc);
      condition1 = fk1 <= f0 + c * alpha * (g0*pk');
      
      pk1 = object_function_grid(xk1, training_factor, train_acc);
      condition2= -1*pk*pk1 <=c2*-1*pk*grad;
      if condition1 %& condition2
          alpha_val = [alpha_val, alpha];
          break;
      end
      if alpha < 1e-32
          break;
      end
      alpha = rho * alpha;
    end
    %}
    
    xk = xk1;
    fk1 = Ojbect_function(xk, training_factor, train_acc);
    tmp_test_loss = Ojbect_function(xk, full_test_Met, test_acc);
    obe_loss =[obe_loss, sqrt(fk1)];
    test_loss = [test_loss, sqrt(tmp_test_loss)];
    
    optgap = f0- fk1;
    gnorm = norm(grad);
    if (abs(optgap) < tol_optgap) | (gnorm < tol_gnorm)
        break;
    end
    if fk1 < 0.0004
        break;
    end
end
% early stopping
w_l = 5;
loss_wei=[];
rate =[];

for kk=1:w_l: length(obe_loss)-w_l
    loss_wei =[loss_wei, mean(obe_loss(kk:kk+w_l-1))];
end
tmp1= loss_wei(1:end-1);
tmp2 = loss_wei(2:end);
err_ = tmp2 - tmp1;
rate = err_;
% > 0
peak_loc = find(rate>0);
if length(peak_loc)<1
    start_point = 1;
else
    start_point = 1;%peak_loc(end)+1;
end

later_part = rate(start_point:end);
th = -0.0010;
flag_ =[];
for ttk=1:length(later_part)-1
    if (later_part(ttk)< th) & (later_part(ttk+1)>= th)
        flag_ = [flag_, ttk];
    end
end
%flag_ = find(later_part< -0.0018);
if length(flag_)< 1
    final_epoch = length(obe_loss)-1;
else
    if length(flag_)<2
    final_epoch = (start_point-1)*w_l+ flag_(1)*w_l-2;
    else
        final_epoch = (start_point-1)*w_l+ flag_(2)*w_l-2;
    end
end

%{
figure
plot(obe_loss, 'linewidth',2)
hold on
plot(test_loss, 'linewidth',2)
legend('train', 'test')
hold on
plot(final_epoch, obe_loss(final_epoch),'*','MarkerSize',12);
%}

optgap;
gnorm;
solve = solution_x(:, final_epoch);
if length(train_acc) > 30
    solve = solution_x(:, 20);
end

%Adam
%{
x = [low_xk, up_xk, w_xk];
grad = object_function_grid(x, training_factor, train_acc);
Op = struct; 
Op.alpha = 0.001; 
[updates, xk_state] = Adam(grad, Op);
xk =grad - updates;

for iteration=1:10000
    f0 =Ojbect_function(xk', training_factor, train_acc);
    grad = object_function_grid(xk', training_factor, train_acc);
    % find the step length
    [xk_update, xk1_state] = Adam(grad, xk_state);
    xk1 = xk - xk_update;
    fk1 = Ojbect_function(xk1', training_factor, train_acc);
    xk = xk1;
    optgap = f0 - fk1;
    gnorm = norm(grad);
    if (optgap < tol_optgap) | (gnorm < tol_gnorm)
        break;
    end
end
%}
end