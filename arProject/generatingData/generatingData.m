%% Generating Test & Training Sets

% Required SetUp: ISET Bio + dependencies, reflectance-display from
% isetcam, cropped_images folder of imagenet photos, trainInd.mat, testInd.mat, and image_matrix from
% cropped_images.mat 

% Function Input: 
% - size of training set
% - position and dimensions of mosaic
% - cone integration time (optional)
% - distance from image (optional)
% - mosaic-centered (optional)

% Function Output: (.mat file in batches of 25:9 train:test, progressively
% named)
% - portions of the image which are important to the mosaic
% - cone absorptions
% - cone mosaic information

% Important Notes:
% - This script will save results in batches of 25 training images and 9
% test images
% - This script will draw from a designated, pre-randomized list of
% possible train and test images. For example, the first 100 images will
% come from the first 100 indexed images in the train list. If 200 images
% is specified, the same 100 images will be used in addition to the next
% 100 images. This will help cut down on processing time for larger
% datasets (not needing to repeat calculations). 
% - This script will use the same cone mosaic for all the training and test
% sets it generates
% - Preferably we want the scene still and the eyes to move, however for
% this to happen, the image must take up the majority of the field of view.
% I hope to run a check to see if scene is large enough for peripheral
% mosaic if mosaic-centered is not specified.

clear
close all

%% Set Sweep Parameters and UPDATE PATH

% Parameters for Dispaly
trainSize = 2;
dist = 0.25;

% Parameters for Cone Mosaic
eccDeg = [-10,0];
cmDim = [1.7,1.7];

% FIX THE PATH TO WHATEVER FOLDER YOU WANT THESE SAVED. DO NOT SAVE OVER
% OTHER FILES. IT WILL MAKE BRIAN CRY.
filepath = 'sets_dim1717_pos1000_dist25_aligned/';

%% Mosaic Generation

[cm] = stableCm('cmPos',eccDeg,'cmDim',cmDim,'integrationTime',10/1000);
cmds = arrayDatastore(cm,"OutputType","same");
save(append(filepath,'cm.mat'),'cmds');

%% Load Cropped Images

load('cropped_images.mat');

%% Calculate Projected Images and Absorptions

[trainds_img, testds_img, trainds_abs, testds_abs, train_list, test_list] = imgToAbs_v2(trainSize, cm, image_matrix,'wantSave',filepath);
