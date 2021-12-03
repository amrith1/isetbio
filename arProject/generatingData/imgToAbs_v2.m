%% Function for Images to Absorptions with a Given Mosaic
% TO DO:
% Flipping and Inverting Image
% Reporting out the scene of importance (if OI is 1:1 with scene then ROI
% should match between them)
% Checking for scene size if not mosaic centered - Check (not robustly
% tested)
% Save the important scene as the mat file for Amrith


function [trainds_img, testds_img, trainds_abs, testds_abs, train_list, test_list] = imgToAbs(trainSize, cm, image_matrix, varargin)
    
    
    % Parse the Inputs
    p = inputParser;
    p.addRequired('trainSize', @isscalar);
    p.addRequired('cm');
    p.addRequired('imageMatrix');
    p.addParameter('distance',0.25,@isscalar);
    p.addParameter('mosaicCentered',true,@islogical);
    p.addParameter('wantSave',pwd,@ischar);
    p.parse(trainSize,cm, image_matrix,varargin{:});
    
    dist = p.Results.distance;
    trainSize = p.Results.trainSize;
    alignCenter = p.Results.mosaicCentered;
    filePath = p.Results.wantSave;
    
    % Load Train and Test Indices 
    
    if isfile('trainInd.mat')
        load('trainInd.mat');
    else
        disp('Please put list of training indices in your file path');
    end
    if isfile('testInd.mat')
        load('testInd.mat');
    else
        disp('Please put list of test indices in your file path');
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
    
    % For Saving 25 pieces at a time
    if trainSize > 25
        numSaves = ceil(trainSize/25);
    else
        numSaves = 1;
    end
    remainingTrain = trainSize;
    remainingTest = testSize;
    
    % Training Absorptions & Images
    for k = 1:numSaves
        if remainingTrain > 25
            train_abs = zeros(1,1,length(cm.coneTypes),25);
            train_list = train_ind((k-1)*25+1:k*25);
            stopTrain = k*25;
        elseif trainSize < 25
            train_abs = zeros(1,1,length(cm.coneTypes),remainingTrain);
            train_list = train_ind(1:trainSize);
            stopTrain = trainSize;
        else
            train_abs = zeros(1,1,length(cm.coneTypes),remainingTrain);
            train_list = train_ind(end-remainingTrain+1:end);
            stopTrain = trainSize;
        end
        if remainingTest > 9
            test_abs = zeros(1,1,length(cm.coneTypes),9);
            test_list = test_ind((k-1)*9+1:k*9);
            stopTest = k*9;
         elseif testSize < 9
            test_abs = zeros(1,1,length(cm.coneTypes),remainingTest);
            test_list = test_ind(1:testSize);
            stopTest = testSize;
        else
            test_abs = zeros(1,1,length(cm.coneTypes),remainingTest);
            test_list = test_ind(end-remainingTest:end);
            stopTest = testSize;
        end
        
        clear train_img
        clear test_img
    
        for i = (k-1)*25+1:stopTrain
        
            % Load Images as a scene
            pngFile = sprintf('%d.png',train_ind(i));
            path = append(path0,pngFile);
            scene = sceneFromFile(path, 'monochrome', [], dispFile);
            scene = sceneSet(scene,'name',pngFile,'distance',dist);
%             vcAddAndSelectObject('scene', scene); 
%             sceneWindow;
        
            % Push image through human optics
            oi = oiCompute(oi, scene);

            % Remove Padding for 1:1 Comparison
            paddedSize = oiGet(oi,'size');
            originalSize = round(paddedSize/1.25);
            offset = round((paddedSize - originalSize) / 2);
            rect = [offset(2)+1 offset(1)+1 originalSize(2)-1 originalSize(1)-2];
            oiCropped = oiCrop(oi,rect);

            % Determine Size of the Scene Visible
            % oiFOV
            oiHfov = oiGet(oiCropped,'hfov');
            oiVfov = oiGet(oiCropped,'vfov');
            % Implant Size (FOV)
            cmDim = cm.sizeDegs;
            %Ratio of implant FOV to oiFOV
            sceneRatio = [cmDim(2)/oiVfov, cmDim(1)/oiHfov];
            % The Size of the Screen Projected onto Retina
            sceneSize = round(sceneRatio.*originalSize);

            % Determine Position of the Scene Visible
            cmPos = cm.eccentricityDegs;

            % If you want the scene to be still, and the eye to move relative
            % to a full FOV
            if alignCenter == false && (cmPos(1)+cmDim(1)/2) <= oiVfov/2 && cmPos(2)+cmDim(2)/2 <= oiHfov/2
                eccRatio = [cmPos(2)/oiVfov, cmPos(1)/oiHfov];
                sceneOffset = round((originalSize - sceneSize + eccRatio.*originalSize)/2);
                sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-1];
                if sceneMap(3) ~= sceneMap(4)
                    sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
                end
                oiScene = oiCrop(oiCropped,sceneMap);
            % If you want scene to be still full FOV, but if your scene is
            % actually too small.
            elseif alignCenter == false && cmPos(1)+cmDim(1)/2 > oiVfov/2 && cmPos(2)+cmDim(2)/2 > oiHfov/2
                % If you want a still scene but cannot
                disp('Desired still scene alignment is too small for desired eccentricity and dimension. Using center-aligned mosaic instead');
                sceneOffset = round((originalSize - sceneSize)/2);
                sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-1];
                if sceneMap(3) ~= sceneMap(4)
                    sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
                end
                oiScene = oiCrop(oiCropped,sceneMap);
            % If you want to align the scene to the very center of mosaic
            % regardless of eccentricity 
            else
                % If you do want to align to center
                sceneOffset = round((originalSize - sceneSize)/2);
                sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-1];
                if sceneMap(3) ~= sceneMap(4)
                    sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
                end
                oiScene = oiCrop(oiCropped,sceneMap);
            end
%             oiWindow(oiScene)

            % Record the Portion of the Scene
            sceneTemp = squeeze(image_matrix(train_ind(i), sceneMap(2):sceneMap(2)+sceneMap(4), sceneMap(1):sceneMap(1)+sceneMap(3)));
            if exist('train_img')
                train_img = cat(3,train_img,sceneTemp);
            else
                train_img = sceneTemp;
            end

            % Calculate Absorption
            train_abs(:,:,:,i) = cm.compute(oiScene);

        end
        
        remainingTrain = trainSize - length(train_list);
        
        for i = (k-1)*9+1:stopTest
            
            pngFile = sprintf('%d.png',test_ind(i));
            path = append(path0,pngFile);
            scene = sceneFromFile(path, 'monochrome', [], dispFile);
            scene = sceneSet(scene,'name',pngFile,'distance',dist);
            vcAddAndSelectObject('scene', scene); 
%             sceneWindow;
            
            % Push image through human optics
            oi = oiCompute(oi, scene);
            
            % Remove the Padding for 1:1 Comparison
            paddedSize = oiGet(oi,'size');
            originalSize = round(paddedSize/1.25);
            offset = round((paddedSize - originalSize) / 2);
            rect = [offset(2)+1 offset(1)+1 originalSize(2)-1 originalSize(1)-2];
            oiCropped = oiCrop(oi,rect);
            
            % Determine which portion of the Scene is Visible
            oiHfov = oiGet(oiCropped,'hfov');
            oiVfov = oiGet(oiCropped,'vfov');
            cmDim = cm.sizeDegs;
            sceneRatio = [cmDim(2)/oiVfov, cmDim(1)/oiHfov];
            sceneSize = round(sceneRatio.*originalSize);
            cmPos = cm.eccentricityDegs;
            
            % If you want the scene to be still, and the eye to move relative
            % to a full FOV
            if alignCenter == false && (cmPos(1)+cmDim(1)/2) <= oiVfov/2 && cmPos(2)+cmDim(2)/2 <= oiHfov/2
                eccRatio = [cmPos(2)/oiVfov, cmPos(1)/oiHfov];
                sceneOffset = round((originalSize - sceneSize + eccRatio.*originalSize)/2);
                sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-1];
                if sceneMap(3) ~= sceneMap(4)
                    sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
                end
                oiScene = oiCrop(oiCropped,sceneMap);
                % If you want scene to be still full FOV, but if your scene is
                % actually too small.
            elseif alignCenter == false && cmPos(1)+cmDim(1)/2 > oiVfov/2 && cmPos(2)+cmDim(2)/2 > oiHfov/2
                disp('Desired still scene alignment is too small for desired eccentricity and dimension. Using center-aligned mosaic instead');
                sceneOffset = round((originalSize - sceneSize)/2);
                sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-1];
                if sceneMap(3) ~= sceneMap(4)
                    sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
                end
                oiScene = oiCrop(oiCropped,sceneMap);
                % If you want to align the scene to the very center of mosaic
                % regardless of eccentricity
            else
                sceneOffset = round((originalSize - sceneSize)/2);
                sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-1];
                if sceneMap(3) ~= sceneMap(4)
                    sceneMap = [sceneOffset(2)+1 sceneOffset(1)+1 sceneSize(2)-1 sceneSize(1)-2];
                end
                oiScene = oiCrop(oiCropped,sceneMap);
                
            end
%             oiWindow(oiScene);
            
            % Record the Portion of the Scene
            sceneTemp = squeeze(image_matrix(test_ind(i), sceneMap(2):sceneMap(2)+sceneMap(4), sceneMap(1):sceneMap(1)+sceneMap(3)));
            if exist('test_img')
                test_img = cat(3,test_img,sceneTemp);
            else
                test_img = sceneTemp;
            end
%             figure;
%             imshow(sceneTemp);
            
            % Calculate absorption
            test_abs(:,:,:,i) = cm.compute(oiScene);
            
        end
        
        train_img = permute(train_img,[3,1,2]);
        test_img = permute(test_img,[3,1,2]);
        trainds_img = arrayDatastore(train_img,"OutputType","same");
        trainds_abs = arrayDatastore(train_abs,"OutputType","same");
        testds_img = arrayDatastore(test_img,"OutputType","same");
        testds_abs = arrayDatastore(test_abs,"OutputType","same");
        
        filename = append(filePath,string((k-1)*25+1),'to',string(stopTrain),'.mat');
        save(filename,'trainds_img','trainds_abs','testds_img','testds_abs','train_list','test_list');
        
    end

    
end
