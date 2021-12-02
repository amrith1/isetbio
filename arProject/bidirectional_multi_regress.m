% returns A_for, b_for such that we minimize E(L2norm ((A_for*x+b_for)-y))

% returns A_rev, b_rev such that we minimize E(L2norm ((A_rev*y+b_rev)-x))

%x and y must both be 2D matrix, the first dimension is number of samples
%which must be same for x and y

function [A_for, b_for, A_rev, b_rev] = bidirectional_multi_regress(x, y)

    i_size = size(x);
    num_x = i_size(2);
    c_size = size(y);
    num_y = c_size(2);
    
    cov_matrix = cov([x, y]);
    x_cov_matrix = cov_matrix(1:num_x,1:num_x);
    y_cov_matrix = cov_matrix(num_x+1:end,num_x+1:end);
    cross_cov = cov_matrix(num_x+1:end, 1:num_x);

    A_for = cross_cov / x_cov_matrix;
    A_rev = cross_cov' / y_cov_matrix;

    x_mean = reshape(mean(x, 1), num_x, 1);
    y_mean = reshape(mean(y, 1), num_y, 1);

    b_for = -1.0 * A_for * x_mean + y_mean;
    b_rev = -1.0 * A_rev * y_mean + x_mean;

end