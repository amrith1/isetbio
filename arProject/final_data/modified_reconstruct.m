%{ 
    Reconstruct images using multiple linear regression model 
    after modifying cone absorptions from testing set, plotting 
    example reconstructions and saving reconstruction statistics to 
    .mat file.
%} 

% Select parameter list
parameter_list = 'dim1717_pos0000_dist25';

% Define simulated RGC selectivity levels
sels = [1 0.99 0.95 0.90 0.80 0.50];

% Select example images from testing set
imgs = [2659 3968 4003];

% Load data
bruh = load([parameter_list '.mat']);
a_test = size(bruh.test_images);
a_train = size(bruh.train_images);
train_images = double(reshape(bruh.train_images, a_train(1), []));
test_images = double(reshape(bruh.test_images, a_test(1), []));
train_cones = bruh.train_cones;
test_cones = bruh.test_cones;

% Run multiple regression
[A, b, mse_train, r_square] = multi_regress_with_pca(train_cones, train_images);
r_square_train = r_square;

% Generates correct dimensions for shaping 'multi' variable below
test_guess = test_cones * A' + b';
test_guess = reshape(test_guess, size(bruh.test_images));

% Evaluate multiple regression with modified cone absorptions
multi = zeros(size(test_guess(1,:,:),2),size(test_guess(1,:,:),3), ...
              1,length(sels)*length(imgs));
ssim_sels = zeros(length(sels),1);
mse_sels = zeros(length(sels),1);
r_square_sels = zeros(length(sels),1);
cnt = 1;

for s = sels
    disp(['Evaluate multiple regression with ' num2str(s) ' selectivity:']);
    % Call function to modify cone absorptions according to desired RGC selectivity
    modified_test_cones = modify_cone_absorptions(parameter_list, s, s, false);
    
    [mse_test, o_var, r_square] = eval_linear_model(modified_test_cones, test_images, A, b);
    r_square_test = r_square;
    test_guess = modified_test_cones * A' + b';
    test_guess = reshape(test_guess, size(bruh.test_images));

    % SSIM calculation
    a_test = size(bruh.test_images);
    num_test = a_test(1);
    im_dim = a_test(2);
    ssims = zeros(num_test,1);
    for i=1:num_test
        ssims(i) = ssim(reshape(test_guess(i,:,:), im_dim, im_dim), reshape(double(bruh.test_images(i,:,:)), im_dim, im_dim));
    end
    ssim_test = mean(ssims);
    
    % Store pre-selected example images from testing set
    subcnt = cnt;
    for i = imgs
        multi(:,:,1,subcnt) = squeeze(test_guess(find(bruh.test_list_all == i),:,:));
        subcnt = subcnt + length(sels);
    end

    ssim_sels(cnt) = ssim_test;
    mse_sels(cnt) = mse_test;
    r_square_sels(cnt) = r_square_test;
    cnt = cnt + 1;
end

% Plot pre-selected example images from testing set across RGC selectivity levels
figure;
for j = 1:length(sels)*length(imgs)
    subplot(length(imgs),length(sels),j);
    imshow(multi(:,:,1,j),'DisplayRange', [0 255]);
end

% Save testing set reconstruction statistics to .mat file
save([parameter_list '_X_sweep_selectivity.mat'],'ssim_sels','mse_sels','r_square_sels');