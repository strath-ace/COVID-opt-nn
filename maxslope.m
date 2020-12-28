function ms = maxslope(net, Dataset, mu, sig,timeWindows, Tmax, italy)

[K N] = size(Dataset);

%% DATA normalisation
D = Dataset';
Dnormalized = ((D - mu(1:end-1))./sig(1:end-1))';

X = zeros(Tmax-timeWindows, (K)*timeWindows);

for n = 1:1:Tmax-timeWindows
    for t = 1:1:timeWindows
        X(n,1+((t-1)*(K)):(K)*t) = Dnormalized(:,t+(n-1));
    end
end

if italy
    XTrain = X(1:end-5,:)';
    XTest = X(end-4:end,:)';
    %% MODEL prediction
    YPredTrain = predict(net{1},XTrain);
    YPredTest = predict(net{1},XTest);
    YPredTrain = sig(end)*YPredTrain + mu(end);
    YPredTest = sig(end)*YPredTest + mu(end);
    YPred = [YPredTrain,YPredTest];
    YPred(YPred < 0) = 0;
else
    XTrain = X(1:end-5,:)';
    XTest = X(end-4:end,:)';
    %% MODEL prediction
    YPredTrain = predict(net,XTrain);
    YPredTest = predict(net,XTest);
    YPredTrain = sig(end)*YPredTrain + mu(end);
    YPredTest = sig(end)*YPredTest + mu(end);
    YPred = [YPredTrain,YPredTest];
    YPred(YPred < 0) = 0;
end

if italy
    ms = max(YPred);
else
    ms = max(YPred);
end


end