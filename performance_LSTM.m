function [rmse,net] = performance_LSTM(vars)

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

Y = (Dnormalized(K,vars.timeWindows+1:end))';
X = zeros(N-vars.timeWindows, (K-1)*vars.timeWindows);

for n = 1:1:N-vars.timeWindows
    for t = 1:1:vars.timeWindows
        X(n,1+((t-1)*(K-1)):(K-1)*t) = Dnormalized(1:end-1,t+(n-1));
    end
end

XTrain = X(1:end-5,:)';
YTrain = Y(1:end-5,:)';
XTest = X(end-4:end,:)';
YTest = Y(end-4:end,:)';

numFeatures = size(XTrain,1);
numResponses = 1;
numHiddenUnits = vars.numHiddenUnits;


layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits,'OutputMode', 'sequence')
    fullyConnectedLayer(vars.FirstLayerSize)
    dropoutLayer(vars.dropoutProb)
    fullyConnectedLayer(numResponses)
    regressionLayer];


options = trainingOptions('adam', ...
    'MaxEpochs',200, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',vars.InitialLearnRate, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',vars.LearnRateDropPeriod, ...
    'LearnRateDropFactor',vars.LearnRateDropFactor, ...
    'Verbose',0, ...
    'Plots','none');

random_seed = rng;
net = trainNetwork(XTrain,YTrain,layers,options);

YPred = predict(net,XTest);

% Unstandardize the predictions using the parameters calculated earlier.
YPred = sig(end)*YPred + mu(end);
YTest = sig(end)*YTest + mu(end);

rmse = sqrt(mean((YPred-YTest).^2));
rmse = rmse/mean(YTest);

if rmse<best_rmse
    best_rmse = rmse;
    best_net = net;
    best_random_seed = random_seed;
    best_vars = vars;
end
end
