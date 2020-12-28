function [rmse,net] = performance_CNN(vars)
 
global best_rmse
global best_net
global best_random_seed
global best_vars
global Dataset

%% Dataset normalisation and split
[K N] = size(Dataset);

D = Dataset';
mu = mean(D);
sig = std(D);

Dnormalized = ((D - mu)./sig)';

Y = (Dnormalized(K,vars.timeWindows+1:end));
X = zeros(K-1, vars.timeWindows,1,N-vars.timeWindows); 

for n = 1:N-vars.timeWindows
    X(:,:,1,n) = Dnormalized(1:K-1,n:vars.timeWindows+(n-1));
end

XTrain = X(:,:,1,1:end-5);
YTrain = Y(1:end-5);
XTest = X(:,:,1,end-4:end);
YTest = Y(end-4:end);

numFeatures = size(XTrain,1);

layers = [
    imageInputLayer([numFeatures vars.timeWindows 1])
    
    convolution2dLayer(vars.CNN_filter,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(vars.CNN_filter,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(vars.CNN_filter,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(vars.CNN_filter,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(vars.CNN_filter,64,'Padding','same')
    batchNormalizationLayer
    reluLayer('Name','rl_out')
    
    dropoutLayer(vars.dropoutLayer_prob,'Name','dropout')
    fullyConnectedLayer(1)
    regressionLayer];

validationFrequency=20;
options = trainingOptions('sgdm', ...
    'MiniBatchSize',vars.miniBatchSize, ...
    'MaxEpochs',200, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',vars.LearnRateDropFactor, ...
    'LearnRateDropPeriod',vars.LearnRateDropPeriod, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XTest,YTest'}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','none', ...
    'Verbose',false);

    random_seed = rng;
    net = trainNetwork(XTrain,YTrain',layers,options);

    YPred = predict(net,XTest);

    % Unstandardize the predictions using the parameters calculated earlier.
    YPred = sig(end)*YPred + mu(end);
    YTest = sig(end)*YTest + mu(end);

    rmse = sqrt(mean((YPred-YTest').^2));
    rmse = rmse/mean(YTest);

if rmse<best_rmse
    best_rmse = rmse;
    best_net = net;
    best_random_seed = random_seed;
    best_vars = vars;
end

end
