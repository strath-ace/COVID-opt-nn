function [fval,cstr, cstreq] = performance_SA(x)

global filename_dataset
global filename_model
global Tmax

%used to plot results
global Dataset_NN
global YPred

load(filename_model)

%% DATA loading
Dataset = readtable(filename_dataset);
Dataset = Dataset{:,:};
[K N] = size(Dataset);
extra = N-Tmax;
italy = 1;

if contains(filename_dataset,"Italy")
    italy = 1;
    Dataset_NN = data_manipulation_for_optimisation(1,Dataset,x);
else
    italy = 0;
    Dataset_NN = data_manipulation_for_optimisation(2,Dataset,x);
end

%% DATA normalisation
D = Dataset_NN';
Dnormalized = ((D - mu(1:end-1))./sig(1:end-1))';
    
if contains(filename_model,"CNN")
    X = zeros(K, best_vars.timeWindows,1,Tmax-best_vars.timeWindows);
    
    for n = 1:Tmax-best_vars.timeWindows
        X(:,:,1,n) = Dnormalized(1:K,n:best_vars.timeWindows+(n-1));
    end
else
    X = zeros(Tmax-best_vars.timeWindows, (K)*best_vars.timeWindows);
    
    for n = 1:1:Tmax-best_vars.timeWindows
        for t = 1:1:best_vars.timeWindows
            X(n,1+((t-1)*(K)):(K)*t) = Dnormalized(:,t+(n-1));
        end
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


%% Computation performance measure (area below cumulative infected curve)
infected = round(cumsum(YPred));
infected_real = round(cumsum(Dataset(end,1:Tmax)));


if italy
    cstr = zeros(1,6);

    cstr(1) = x(1)-x(2);
    cstr(2) = x(2)-x(3);
    cstr(3) = x(7)+sum(x(8:11))-Tmax;
    cstr(4) = x(12)+sum(x(13:19))-Tmax;

    idx = find(infected>0,1);
    cstr(5) = idx-1;
    cstr(6) = 1-idx;

    fval = max(YPred);
else
    cstr = zeros(1,17);
    cstr(1) = x(1) - x(2);
    cstr(2) = x(3) - x(4);
    cstr(3) = x(5) - x(7);
    cstr(4) = x(7) - x(6);
    cstr(5) = x(8) - x(6);
    cstr(6) = x(8) - x(9);
    cstr(7) = x(9) - x(6);
    cstr(8) = x(10) - x(6);
    cstr(9) = x(11) - x(6);
    cstr(10) = x(10) - x(11);
    cstr(11) = x(12) - x(6);
    cstr(12) = x(12) - x(11);

    
    cstr(13) = x(13)+sum(x(14:19))-Tmax;
    cstr(14) = x(21)+sum(x(22:28))-Tmax;
    cstr(15) = x(29)+sum(x(30:46))-Tmax;
    
    idx = find(infected>0,1);
    cstr(16) = idx-1;
    cstr(17) = 1-idx;

    fval = max(YPred);
end

cstreq=[];

end
