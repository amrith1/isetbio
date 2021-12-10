function [train_ind, test_ind] = trainTestInd(path0,width,height)
% you can choose whether to specify a path or not. If you do not specify
% a path, the default will assume the imagenet folder is in your current
% directory.

    if ~exist('path0')     
        path0 = pwd;
        path0 = append(path0, '/cropped_images/');
    end
    if ~exist('width','var') 
        width = 450;
    end
    if ~exist('height','var')
        height = 300;
    end
    
    
    % Find Total Possible Images
    all_img = dir([path0 '*.png']);
    
    % Only Load Those of the Same Size
    img_ind = zeros(size(all_img,1),1);
    
    for i = 1:size(all_img,1)
        
        pngFile = all_img(i).name;
        path = append(path0, pngFile);
        info = imfinfo(path);
    
        if info.Width == width && info.Height == height
            img_ind(i) = str2num(all_img(i).name(1:end-4));
        end
    
    end
    
    img_ind = img_ind(img_ind~=0);

    % Randomly Split All Images into Train and Test Sets with a 75:25 Split
    train_size = round(length(img_ind)*.75);
   
    img_ind = randsample(img_ind, length(img_ind));
    
    train_ind = img_ind(1:train_size);
    test_ind = img_ind(train_size+1:end);
    

end
