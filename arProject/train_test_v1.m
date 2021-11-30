%% TRAINING AND TEST SET FORMATION
% GOAL: Form a training and test set for image reconstruction from cone
% absorptions. These sets will be randomly chosen from landscape oriented
% imagenet photos within the grayscale_full folder. They will consist of an
% image matrix and a corresponding cone absorption matrix. 

% Required SetUp: ISET Bio + dependencies, reflectance-display from
% isetcam, grayscale_full folder of imagenet photos

% Necessary Inputs:
% Size of training set (75% training and 25% test)
% Size and Location of Cone Matrix

% Optional Inputs:
% Cone Integration Time
% Display Size
% Desired Visualizations

% Assumptions:
% Human optics adjustment of a scene
% Display is as close to natural lighting as possible
% Cone Integration within Human Visual Integration Window
% TO DO: Display flipped accordingly & check linearity

clear
close all

%% Input Parameters

train_size = 15; %Number of images you want for your training
cm_dimx = 3.4;  % in deg (3.4 deg ~ 1mm)
cm_dimy = 3.4; % in deg (3.4 deg ~ 1mm)
cm_posx = -10; % in deg eccentricity (-10 deg ~ raphe)
cm_posy = 0; % in deg eccentricity (0 deg ~ raphe)

cone_vis = true; % boolean, plot cone mosaic or not
int_time = 10/1000; % integration time for cones in sec (10-15ms biologically reasonable)
disp_xlen = 0.42; % display width in meters
disp_ylen = 0.24; % display height in meters

%% Form Index of Images to Use

total_img = ceil(train_size / 0.75);
test_size = total_img - train_size;

% Reduce possible images to landscape only orientations
land_ind = land_only(); % takes about 30 sec

% Randomly choose images from land_ind without replacement in any order
all_img = randsample(land_ind, total_img);
% Split according to size of desired datasets 
train_ind = all_img(1:train_size); 
test_ind = all_img(train_size+1:total_img);


%% Initialize

ieInit;

%% Form Cone Mosaic

%Potentially add noise flag or vary macular pigment density with
%eccentricity or vary cone blue with eccentricity to cMosaic
% Potentially useful properties of cm for all cones:
% coneRFpositionsMicrons, coneRFpositionsDegs, lconeIndices, mconeIndices,
% sconeIndices, coneTypes (1=L, 2=M, 3=S)

cm = cMosaic('sizeDegs',[cm_dimx, cm_dimy],'eccentricityDegs',[cm_posx, cm_posy]);

cm.integrationTime = int_time;
if cone_vis == true
    
    cm.visualize();
    
end

% Create Cone Mosaic Datastore - This is still very large, could prob be
% reduced by limiting to only necessary and independent variables
cmds = arrayDatastore(cm,"OutputType","same");

%% Create Human Optics

oi = oiCreate('human');

%% Prep Display

dispFile = 'reflectance-display.mat';

%Question: Do I have to flip it or does that
%happen automatically in the cone computation?

% Calculate the length of the display in degrees
disp_xdeg = atand(disp_xlen / 2 / 0.6);
disp_ydeg = atand(disp_ylen / 2 / 0.6);

%% Prep Path to Images

% Path to access the photos - future fix: make into function where path can
% be speficied if desired
path0 = pwd;
path0 = append(path0, '/grayscale_full/');

% Time Estimates
totalTime = 0;

%% Form Training Set

train_path = strings(length(train_ind),1);
train_abs = zeros(1,1,length(cm.coneTypes),length(train_ind));

for i = 1:length(train_ind)
    
    tic;
    
    % Make image into an isetbio scene
    pngFile = sprintf('%d.png', train_ind(i));
    path = append(path0, pngFile);
    scene = sceneFromFile(path, 'monochrome', [], dispFile);
    scene = sceneSet(scene,'name',pngFile,'distance',0.6); % 0.6 m falls within recommended distance from computer screen
%    vcAddAndSelectObject('scene', scene); % Not sure this is necessary (I think this is for if you want to be able to look at all your scenes)
%    sceneWindow(scene);
    
    % Record path name for datastore
    train_path(i) = path;
   
    % Push image through human optics
    oi = oiCompute(oi, scene);
    %oiWindow(oi);
    
    % Crop optical image to portion only concerned with our cones
    oi_center = oiGet(oi, 'centerpixel'); oi_ycenter = oi_center(1); oi_xcenter = oi_center(2); % center of display
    % Find top left corner for reference
    deg_x0 = disp_xdeg + cm_posx - cm_dimx; % deg out from display to top left portion of the retinal scene
    deg_y0 = disp_ydeg - cm_posy - cm_dimy;
    oi_x0 = round(oi_xcenter * (deg_x0 / disp_xdeg)); % oi measure of display to top left portion of retinal scene
    oi_y0 = round(oi_ycenter * (deg_y0 / disp_ydeg));
    % Determine size of cropped scene that matters
    deg_xlen = cm_dimx*2;
    deg_ylen = cm_dimy*2;
    oi_xlen = round(oi_xcenter * (deg_xlen / disp_xdeg));
    oi_ylen = round((cm_dimy / cm_dimx) *oi_xlen);
    % Form measures to crop oi
    rect = [oi_x0 oi_y0 oi_xlen oi_xlen];
    % Crop oi
    oiCones = oiCrop(oi, rect);
    
    %oiWindow(oiCones);
    
    % Calculate absorption
    train_abs(:,:,:,i) = cm.compute(oi);
    
    % Visualize Absorptions
    %params = cm.visualize('params');
    %params.activation = absorptions.^0.5;
    %params.activationColorMap = hot(1024);
    %cm.visualize(params);
    
    timeElapsed = toc;
    totalTime = totalTime + timeElapsed;
    avgTime = totalTime / i;
    estTime = (avgTime * (length(train_ind) - i + length(test_ind)))/60;
    disp(avgTime);
    disp(estTime);
    
end


%% Form Test Set

test_path = strings(length(test_ind),1);
test_abs = zeros(1,1,length(cm.coneTypes),length(test_ind));

for i = 1:length(test_ind)
    
    tic;
    
    % Make image into an isetbio scene
    pngFile = sprintf('%d.png', test_ind(i));
    path = append(path0, pngFile);
    scene = sceneFromFile(path, 'monochrome', [], dispFile);
    scene = sceneSet(scene,'name',pngFile,'distance',0.6); % 0.6 m falls within recommended distance from computer screen
    %    vcAddAndSelectObject('scene', scene); % Not sure this is necessary (I think this is for if you want to be able to look at all your scenes)
    %    sceneWindow(scene);
    
    
    test_path(i) = path;

    % Push image through human optics
    oi = oiCompute(oi, scene);
    %oiWindow(oi);
    
    % Crop optical image to portion only concerned with our cones
    oi_center = oiGet(oi, 'centerpixel'); oi_ycenter = oi_center(1); oi_xcenter = oi_center(2); % center of display
    % Find top left corner for reference
    deg_x0 = disp_xdeg + cm_posx - cm_dimx; % deg out from display to top left portion of the retinal scene
    deg_y0 = disp_ydeg - cm_posy - cm_dimy;
    oi_x0 = round(oi_xcenter * (deg_x0 / disp_xdeg)); % oi measure of display to top left portion of retinal scene
    oi_y0 = round(oi_ycenter * (deg_y0 / disp_ydeg));
    % Determine size of cropped scene that matters
    deg_xlen = cm_dimx*2;
    deg_ylen = cm_dimy*2;
    oi_xlen = round(oi_xcenter * (deg_xlen / disp_xdeg));
    oi_ylen = round((cm_dimy / cm_dimx) *oi_xlen);
    % Form measures to crop oi
    rect = [oi_x0 oi_y0 oi_xlen oi_xlen];
    % Crop oi
    oiCones = oiCrop(oi, rect);
    %oiWindow(oiCones);
    
    % Calculate absorption
    test_abs(:,:,:,i) = cm.compute(oi);
    
    % Visualize Absorptions
    %params = cm.visualize('params');
    %params.activation = absorptions.^0.5;
    %params.activationColorMap = hot(1024);
    %cm.visualize(params);
    
    elapsedTime = toc;
    totalTime = totalTime + elapsedTime;
    avgTime = totalTime / (i + length(train_ind));
    estTime = (avgTime * (length(test_ind) - i))/60;
    disp(avgTime);
    disp(estTime);
    
end

%%  Save as Train and Test Sets as Datastores

trainds_img = imageDatastore(train_path,"FileExtensions",".png","Labels",string(train_ind));
trainds_abs = arrayDatastore(train_abs,"OutputType","same");
testds_img = imageDatastore(test_path,"FileExtensions",".png","Labels",string(test_ind));
testds_abs = arrayDatastore(test_abs,"OutputType","same");

%% Save Datastores in One .mat File

save('trainTestSetsV1.mat','trainds_img','trainds_abs','testds_img','testds_abs');
save('cmCharV1.mat','cmds');
