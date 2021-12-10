%% Function for Images to Absorptions with a Given Mosaic
% TO DO:
% Flipping and Inverting Image
% Reporting out the scene of importance (if OI is 1:1 with scene then ROI
% should match between them)
% Checking for scene size if not mosaic centered - Check (not robustly
% tested)
% Saving, wantSave with a path
% Save the important scene as the mat file for Amrith


function [trainds_img, trainds_abs, testds_img, testds_abs, oiCropped] = imgToAbs( trainSize, cm, varargin)
   
    % Parse the Inputs
    
    p = inputParser;
    p.addRequired('trainSize', @isscalar);
    p.addRequired('cm');
    p.addParameter('distance',0.25,@isscalar);
    p.addParameter('mosaicCentered',true,@islogical);
    p.addParameter('wantSave',false,@islogical);
    p.addParameter('whatSave',50,@isscalar);
    p.parse(trainSize,cm, varargin{:});
    
    dist = p.Results.distance;
    trainSize = p.Results.trainSize;
    alignCenter = p.Results.mosaicCentered;
    
    % Load Train and Test Indices 
    
    if isfile('trainInd.mat')
        load('trainInd.mat','train_ind');
    else
        disp('Please put list of training indices in your file path');
    end
    if isfile('testInd.mat')
        load('testInd.mat', 'test_ind');
    else
        disp('Please put list of test indices in your file path');
    end
    if isfile('cropped_images.mat')
        load('cropped_images.mat','image_matrix')
    end
    
    % Form Index of Images to Use
    if trainSize > length(train_ind)
        trainSize = length(train_ind);
        testSize = length(test_ind);
        disp('Desired training set size larger than maximum allowed. Training set size reduced to maximum.');
    else
        testSize = ceil(trainSize/0.75) - trainSize;
    end
    
    % Create Human Optics
    oi = oiCreate('human');
    oi = oiSet(oi, 'distance', dist);
    
    % Prep Display & Image Paths
    dispFile = 'reflectance-display.mat';
    path0 = pwd;
    path0 = append(path0, '/cropped_images/');
    
    train_path = strings(length(trainSize),1);
    train_abs = zeros(1,1,length(cm.coneTypes),length(trainSize));
%    train_img = zeros(length(trainSize),size(image_matrix,2),size(image_matrix,3));
    
    for i = 1:trainSize
        
        pngFile = sprintf('%d.png',train_ind(i));
        path = append(path0,pngFile);
        scene = sceneFromFile(path, 'monochrome', [], dispFile);
        scene = sceneSet(scene,'name',pngFile,'distance',dist);
        vcAddAndSelectObject('scene', scene); % Not sure this is necessary (I think this is for if you want to be able to look at all your scenes)
        sceneWindow(scene);
        
        % Record path name for datastore
        train_path(i) = path;
        
        % Push image through human optics
        oi = oiCompute(oi, scene);
        oiWindow(oi);
        
        % Remove Padding for 1:1 Comparison
        paddedSize = oiGet(oi,'size');
        originalSize = round(paddedSize/1.25);
        offset = round((paddedSize - originalSize) / 2);
        rect = [offset(2)+1 offset(1)+1 originalSize(2)-1 originalSize(1)-2];
        oiCropped = oiCrop(oi,rect);
        oiWindow(oiCropped);
        
                % Determine which portion of the Scene is Visible
        oiHfov = oiGet(oiCropped,'hfov');
        oiVfov = oiGet(oiCropped,'vfov');
        cmDim = cm.sizeDegs;
        sceneRatio = [cmDim(2)/oiVfov, cmDim(1)/oiHfov];
        sceneSize = round(sceneRatio.*originalSize);
        cmPos = cm.eccentricityDegs;
        
        if alignCenter == false && (cmPos(1)+cmDim(1)/2) <= oiVfov/2 && cmPos(2)+cmDim(2)/2 <= oiHfov/2
            eccRatio = [cmPos(2)/oiVfov, cmPos(1)/oiHfov];
            sceneOffset = round((originalSize - sceneSize + eccRatio.*originalSize)/2);
            sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2]
            oiScene = oiCrop(oiCropped,sceneMap);
            oiWindow(oiScene);
            
        elseif alignCenter == false && cmPos(1)+cmDim(1)/2 > oiVfov/2 && cmPos(2)+cmDim(2)/2 > oiHfov/2
            % If you want a still scene but cannot
            disp('Desired still scene alignment is too small for desired eccentricity and dimension. Using center-aligned mosaic instead');
            sceneOffset = round((originalSize - sceneSize)/2);
            sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2]
            oiScene = oiCrop(oiCropped,sceneMap);
            oiWindow(oiScene);
            
        else
            % If you do want to align to center
            sceneOffset = round((originalSize - sceneSize)/2);
            sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2]
            oiScene = oiCrop(oiCropped,sceneMap);
            oiWindow(oiScene);
            
        end

        % Record the Portion of the Scene 
        %train_img(i,:,:) = image_matrix(train_ind(i),:,:);
        
        % Calculate absorption
        train_abs(:,:,:,i) = cm.compute(oiScene);
        
        % Visualize Absorptions
        params = cm.visualize('params');
        params.activation = train_abs(1,1,:,i).^0.5;
        params.activationColorMap = hot(1024);
        cm.visualize(params);
        
    end
    
    test_path = strings(length(testSize),1);
    test_abs = zeros(1,1,length(cm.coneTypes),length(testSize));
   % test_img = zeros(length(trainSize),size(image_matrix,2),size(image_matrix,3));
    
    for i = 1:testSize
        
        pngFile = sprintf('%d.png',test_ind(i));
        path = append(path0,pngFile);
        scene = sceneFromFile(path, 'monochrome', [], dispFile);
        scene = sceneSet(scene,'name',pngFile,'distance',dist);
        vcAddAndSelectObject('scene', scene); % Not sure this is necessary (I think this is for if you want to be able to look at all your scenes)
        sceneWindow(scene);
        
        % Record path name for datastore
        test_path(i) = path;
        
        % Push image through human optics
        oi = oiCompute(oi, scene);
        oiWindow(oi);
        
        % Remove the Padding for 1:1 Comparison
        paddedSize = oiGet(oi,'size');
        originalSize = round(paddedSize/1.25);
        offset = round((paddedSize - originalSize) / 2);
        rect = [offset(2)+1 offset(1)+1 originalSize(2)-1 originalSize(1)-2];
        oiCropped = oiCrop(oi,rect);
        oiWindow(oiCropped);
        
        % Determine which portion of the Scene is Visible
        oiHfov = oiGet(oiCropped,'hfov');
        oiVfov = oiGet(oiCropped,'vfov');
        cmDim = cm.sizeDegs;
        sceneRatio = [cmDim(2)/oiVfov, cmDim(1)/oiHfov];
        sceneSize = round(sceneRatio.*originalSize);
        cmPos = cm.eccentricityDegs;
        
        if alignCenter == false && (cmPos(1)+cmDim(1)/2) <= oiVfov/2 && cmPos(2)+cmDim(2)/2 <= oiHfov/2
            eccRatio = [cmPos(2)/oiVfov, cmPos(1)/oiHfov];
            sceneOffset = round((originalSize - sceneSize + eccRatio.*originalSize)/2);
            sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
            oiScene = oiCrop(oiCropped,sceneMap);
            oiWindow(oiScene)
            
        elseif alignCenter == false && cmPos(1)+cmDim(1)/2 > oiVfov/2 && cmPos(2)+cmDim(2)/2 > oiHfov/2
            % If you want a still scene but cannot
            disp('Desired still scene alignment is too small for desired eccentricity and dimension. Using center-aligned mosaic instead');
            sceneOffset = round((originalSize - sceneSize)/2);
            sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
            oiScene = oiCrop(oiCropped,sceneMap);
            oiWindow(oiScene)
            
        else
            % If you do want to align to center
            sceneOffset = round((originalSize - sceneSize)/2);
            sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2]
            oiScene = oiCrop(oiCropped,sceneMap);
            oiWindow(oiScene)
            
        end
        
        % Make this Scene Into a Variable
        %test_img(i,:,:) = image_matrix(test_ind(i),:,:);
        
        % Calculate absorption
        test_abs(:,:,:,i) = cm.compute(oiScene);
        
        % Visualize Absorptions
        params = cm.visualize('params');
        params.activation = test_abs(1,1,:,i).^0.5;
        params.activationColorMap = hot(1024);
        cm.visualize(params);
        
    end
    
    trainds_img = imageDatastore(train_path,"FileExtensions",".png");
    trainds_abs = arrayDatastore(train_abs,"OutputType","same");
    testds_img = imageDatastore(test_path,"FileExtensions",".png");
    testds_abs = arrayDatastore(test_abs,"OutputType","same");
    
    if p.Results.wantSave == true
        filename = append('sets_trainImg', string(trainSize), '_testImg', string(testSize), '_dimPos', string(cm.sizeDegs(1,1)),string(cm.eccentricityDegs(1,1)),'_intTime',string(cm.integrationTime),'_aligned',string(alignedCenter));
        save(append(filename,'.mat'),'trainds_img','trainds_abs','testds_img','testds_abs');
        save(append(filename,'_cm.mat'), 'cm'); 
    end
    
end
