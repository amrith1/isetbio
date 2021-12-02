function [A, b, mse, r_square] = cone_regress(image_mat_path, image_indices, top, bottom, left, right, cone_abs)
    image_matrix = single(load(image_mat_path).image_matrix);
    image_matrix = image_matrix(image_indices, top:bottom, left:right);
    num_indices = size(reshape(image_indices, [], 1));
    num_indices = num_indices(1);
    image_matrix = reshape(image_matrix, num_indices, []);
    size(image_matrix);
    [A, b, mse, r_square] = multi_regress(cone_abs, image_matrix);
end