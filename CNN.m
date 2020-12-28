function [opt_vars] = CNN(filename)

global best_rmse
global best_net
global best_random_seed
global best_vars
global Dataset

%% DATA preparation
Dataset = readtable(filename);
Dataset = Dataset{:,:};

if contains(filename,"Italy")
    Dataset = process_Italy_data(Dataset);
elseif contains(filename,"Taiwan")
    Dataset = process_Taiwan_data(Dataset);
else
    disp('Problem with dataset')
    return
end

D = Dataset';
mu = mean(D);
sig = std(D);

%% OPTIMISATION HYPERPARAMETERS and TRAINING
% Define hyperparameters to optimize

vars = [optimizableVariable('miniBatchSize', [10,100], 'Type', 'integer');
    optimizableVariable('CNN_filter', [5,14], 'Type', 'integer');
    optimizableVariable('timeWindows', [7,21], 'Type', 'integer');
    optimizableVariable('LearnRateDropFactor', [0,0.5], 'Type', 'real');
    optimizableVariable('LearnRateDropPeriod', [10, 20], 'Type', 'integer');
    optimizableVariable('dropoutLayer_prob', [0, 0.7], 'Type', 'real')];

% Optimize
best_rmse = 1e06;
best_net = [];
best_random_seed=0;
best_vars=[];
minfn = @performance_CNN;
results = bayesopt(minfn, vars,'IsObjectiveDeterministic', false,...
    'AcquisitionFunctionName', 'expected-improvement-plus','MaxObjectiveEvaluations',200, 'NumSeedPoints',30);
   
opt_vars = bestPoint(results);
if contains(filename,"Italy")
    save(strcat("IT_best_CNN",num2str(round(best_rmse*1000)),".mat"), 'Dataset', 'mu', 'sig', 'best_net', 'best_rmse', 'best_random_seed', 'best_vars')
elseif contains(filename,"Taiwan")
    save(strcat("xxxTW_best_CNN",num2str(round(best_rmse*10000)),".mat"), 'Dataset', 'mu', 'sig', 'best_net', 'best_rmse', 'best_random_seed', 'best_vars')
end

end