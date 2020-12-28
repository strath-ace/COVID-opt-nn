function [rmse, net] = performance_ELM(vars)

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

XTrain = X(1:end-5,:);
YTrain = Y(1:end-5,:);
XTest = X(end-4:end,:);
YTest = Y(end-4:end,:);

%% DATA normalisation and split

numFeatures = size(XTrain,2);
numResponses = 1;

random_seed = rng;
% Estimate parameters
W = rand(vars.S,numFeatures)*2-1;
Bias = rand(vars.S,1);
BiasMatrix = repmat(Bias,1,size(XTrain,1));
P = (W*XTrain'+ BiasMatrix)';
H = 1./(1+exp(-P));
Beta = inv(H'*H + (eye(vars.S)./vars.C))*H'*YTrain;

% Compute output for the test set
BiasMatrix = repmat(Bias,1,size(XTest,1));
P = (W*XTest'+ BiasMatrix)';
Htest = 1./(1+exp(-P));
YPred = Htest*Beta;

% Unstandardize the predictions using the parameters calculated earlier.
YPred = sig(end)*YPred + mu(end);
YTest = sig(end)*YTest + mu(end);

rmse= sqrt(mean((YPred-YTest).^2));
rmse = rmse/mean(YTest);

net = {W;Bias;Beta};

if rmse<best_rmse
    best_rmse = rmse;
    best_net = {W;Bias;Beta};
    best_random_seed = random_seed;
    best_vars = vars;
end
end
