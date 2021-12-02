function [mse, r_square] = eval_linear_model(x_test, y_test, A, b)
    o_var = sum(var(y_test - mean(y_test, 1)));
    errors = x_test * A' + b' - y_test;
    mse = sum((errors.^2));
    r_square = (o_var - mse)/o_var;
end