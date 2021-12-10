%{ 
    Gather distributed datastores into unified datastores for 
    neural network models.
%} 

% Run within data directory of interest
% Make sure train_batch and test_batch are correct sizes
path = '*to*.mat';
datastores = dir(path);

train_batch = 25;
test_batch = 9;

% Convert batches of 25 into one datastore
train_cell = cell(train_batch*length(datastores),2);
test_cell = cell(test_batch*length(datastores),2);
train_list_all = zeros(train_batch*length(datastores),1);
test_list_all = zeros(test_batch*length(datastores),1);

datastores = {datastores.name};
cnt = 0;
for d = datastores
    filename = char(d);
    load(filename,'trainds_img','trainds_abs','testds_img','testds_abs','train_list','test_list');
    train_img = readall(trainds_img);
    test_img = readall(testds_img);
    train_abs = transpose(squeeze(readall(trainds_abs)));
    test_abs = transpose(squeeze(readall(testds_abs)));

    indices = str2double(split(filename(1:end-4),'to'));
    from = indices(1);
    to = indices(2);

    test_to = to * test_batch / train_batch;
    test_from = test_to - (test_batch - 1);

    train_abs = train_abs(from:to,:);
    test_abs = test_abs(test_from:test_to,:);

    train_cell(from:to,2) = mat2cell(train_img, ones(train_batch,1));
    train_cell(from:to,1) = mat2cell(train_abs, ones(train_batch,1));

    test_cell(test_from:test_to,2) = mat2cell(test_img, ones(test_batch,1));
    test_cell(test_from:test_to,1) = mat2cell(test_abs, ones(test_batch,1));

    train_list_all(from:to,1) = train_list;
    test_list_all(test_from:test_to,1) = test_list;

    cnt = cnt + 1;
    disp(cnt/length(datastores));
end

disp('Reshaping...');
% Reshape datastores
for r = 1:size(train_cell, 1)
    % Attempt for feature-based NN
    %temp = reshape(train_cell{r,2},[],1);
    %train_cell(r,2) = mat2cell(temp,length(temp));

    %temp = reshape(train_cell{r,1},[],1);
    %train_cell(r,1) = mat2cell(temp,length(temp));
    %----------------------------------------------------------------
    % Attempt for resizing absorptions to fit image size
    %output = squeeze(train_cell{r,2});
    %output_dim = length(output);
    %train_cell(r,2) = mat2cell(output,output_dim,output_dim);

    %input = train_cell{r,1};
    %input_dim = floor(sqrt(length(temp)));
    %input = reshape(temp(1,1:input_dim^2),input_dim,input_dim);
    %input = imresize(input,[output_dim,output_dim],'nearest');
    %train_cell(r,1) = mat2cell(input,output_dim,output_dim);
    %----------------------------------------------------------------
    % Attempt for resizing image size to fit 2d absorptions
    input = train_cell{r,1};
    input_dim = floor(sqrt(length(input)));
    input = reshape(input(1,1:input_dim^2),input_dim,input_dim);
    train_cell(r,1) = mat2cell(input,input_dim,input_dim);

    output = squeeze(train_cell{r,2});
    output = imresize(output,[input_dim,input_dim],'bicubic');
    train_cell(r,2) = mat2cell(output,input_dim,input_dim);
    %----------------------------------------------------------------
    % Attempt using PCA
    %input = train_cell{r,1};
    %coeff = pca(input)
    %input_dim = length(coeff);
    %train_cell(r,1) = mat2cell(coeff,input_dim,input_dim);

    %output = squeeze(train_cell{r,2});
    %output = imresize(output,[input_dim,input_dim],'bicubic');
    %train_cell(r,2) = mat2cell(output,input_dim,input_dim);
end

for r = 1:size(test_cell, 1)
    % Attempt for feature-based NN
    %temp = reshape(test_cell{r,2},[],1);
    %test_cell(r,2) = mat2cell(temp,length(temp));

    %temp = reshape(test_cell{r,1},[],1);
    %test_cell(r,1) = mat2cell(temp,length(temp));
    %----------------------------------------------------------------
    % Attempt for resizing absorptions to fit image size
    %output = squeeze(test_cell{r,2});
    %output_dim = length(output);
    %test_cell(r,2) = mat2cell(output,output_dim,output_dim);

    %input = test_cell{r,1};
    %input_dim = floor(sqrt(length(temp)));
    %input = reshape(temp(1,1:input_dim^2),input_dim,input_dim);
    %input = imresize(input,[output_dim,output_dim],'nearest');
    %test_cell(r,1) = mat2cell(input,output_dim,output_dim);
    %----------------------------------------------------------------
    % Attempt for resizing image size to fit 2d absorptions
    input = test_cell{r,1};
    input_dim = floor(sqrt(length(input)));
    input = reshape(input(1,1:input_dim^2),input_dim,input_dim);
    test_cell(r,1) = mat2cell(input,input_dim,input_dim);

    output = squeeze(test_cell{r,2});
    output = imresize(output,[input_dim,input_dim],'bicubic');
    test_cell(r,2) = mat2cell(output,input_dim,input_dim);
    %----------------------------------------------------------------
    % Attempt using PCA
    %input = test_cell{r,1};
    %coeff = pca(input)
    %input_dim = length(coeff);
    %test_cell(r,1) = mat2cell(coeff,input_dim,input_dim);

    %output = squeeze(test_cell{r,2});
    %output = imresize(output,[input_dim,input_dim],'bicubic');
    %test_cell(r,2) = mat2cell(output,input_dim,input_dim);
end

% Make datastores and save in .mat file
trainds_cell = arrayDatastore(train_cell,'OutputType','same');
testds_cell = arrayDatastore(test_cell,'OutputType','same');
filename = 'all.mat';
save(filename,'trainds_cell','testds_cell','train_list_all','test_list_all');
disp('Done.');