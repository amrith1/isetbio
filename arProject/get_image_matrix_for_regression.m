function [image_matrix] = get_image_matrix_for_regression(image_mat_path, image_indices, top, bottom, left, right)
    image_matrix = single(load(image_mat_path).image_matrix);
    image_matrix = image_matrix(image_indices, top:bottom, left:right);
    num_indices = size(reshape(image_indices, [], 1));
    num_indices = num_indices(1);
    image_matrix = reshape(image_matrix, num_indices, []);
end