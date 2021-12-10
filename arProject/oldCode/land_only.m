function [land_ind] = land_only(path0)
% you can choose whether to specify a path or not. If you do not specify
% a path, the default will assume the imagenet folder is in your current
% directory.

    if ~exist('path0')
        
        path0 = pwd;
        path0 = append(path0, '/grayscale_full/');
        
    end
    
    land_ind = zeros(5500,1);
    
    for i = 1:5500
    
    pngFile = sprintf('%d.png', i);
    path = append(path0, pngFile);
    info = imfinfo(path);
    
        if info.Width > info.Height
            land_ind(i,1) = i;
        end
    
    end
    
    land_ind = nonzeros(land_ind);

end
