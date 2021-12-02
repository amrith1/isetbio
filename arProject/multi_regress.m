% returns A, b such that we minimize E(L2norm ((Ax+b) - y))
%x and y must both be 2D matrix, the first dimension is number of samples
%which must be same for x and y

function [A, b, mse, r_square] = multi_regress(x, y)

    i_size = size(x);
    num_x = i_size(2);
    c_size = size(y);
    num_y = c_size(2);
    
    cov_matrix = cov([x, y]);
    x_cov_matrix = cov_matrix(1:num_x,1:num_x);
    cross_cov = cov_matrix(num_x+1:end, 1:num_x);
    A = cross_cov / x_cov_matrix;
    x_mean = reshape(mean(x, 1), num_x, 1);
    y_mean = reshape(mean(y, 1), num_y, 1);
    b = -1.0 * A * x_mean + y_mean;
    errors = x * A' + b' - y;
    mse = sum(var(errors));
    o_var = sum(var(y - mean(y, 1)));
    r_square = (o_var - mse)/o_var;
end