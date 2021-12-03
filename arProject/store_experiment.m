function store_experiment(distance, cm_dim, cm_posx, top, bottom, left, right, train_indices, test_indices, train_cones, test_cones)
    file_name = 'distance' + string(distance) + '_cmdim_' + string(cm_dim) + '_xecc_' + string(cm_posx);
    %file_name = strrep(file_name, '.', '');
    file_name = file_name + '.mat'
    train_indices = reshape(train_indices, [], 1);
    test_indices = reshape(test_indices, [], 1);
    save(file_name, 'distance', 'cm_dim', 'cm_posx', 'top', 'bottom', 'left', 'right', 'train_indices', 'test_indices', 'train_cones', 'test_cones')
end