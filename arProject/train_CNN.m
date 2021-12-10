%{ 
    Train convolutional neural network (CNN) architectures.
%} 

layers = [
    imageInputLayer([52 52 1])  % Initial image is 52x52
    convolution2dLayer(5,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(5,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
  
    convolution2dLayer(5,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(5,1,'Padding','same')
    batchNormalizationLayer
    reluLayer
      
    dropoutLayer(0.2)
    regressionLayer];

%miniBatchSize = 100;
%options = trainingOptions('adam', ...
%    'MiniBatchSize', miniBatchSize, ...
%    'Shuffle','every-epoch', ...
%    'Plots','training-progress', ...
%    'Verbose',false);

maxEpochs = 100;
miniBatchSize = 100;
epochIntervals = 1;
initLearningRate = 0.1;
learningRateFactor = 0.1;
l2reg = 0.0001;
options = trainingOptions('sgdm', ...
    'Momentum',0.9, ...
    'InitialLearnRate',initLearningRate, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',learningRateFactor, ...
    'L2Regularization',l2reg, ...
    'MaxEpochs',maxEpochs ,...
    'MiniBatchSize',miniBatchSize, ...
    'GradientThresholdMethod','l2norm', ...
    'Plots','training-progress', ...
    'GradientThreshold',0.01);

net = trainNetwork(trainds_cell,layers,options)