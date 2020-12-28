function [opt_vars] = LSTM(filename)

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
vars = [optimizableVariable('timeWindows', [7,21], 'Type', 'integer');
    optimizableVariable('numHiddenUnits', [100,800], 'Type', 'integer');
    optimizableVariable('FirstLayerSize', [100,500], 'Type', 'integer');
    optimizableVariable('dropoutProb', [0,1], 'Type', 'real');
    optimizableVariable('InitialLearnRate', [0,0.005], 'Type', 'real');
    optimizableVariable('LearnRateDropPeriod', [50,150], 'Type', 'integer');
    optimizableVariable('LearnRateDropFactor', [0,0.05], 'Type', 'real')];

% Optimize
best_rmse = 1e06;
best_net = [];
best_random_seed=0;
best_vars=[];
minfn = @performance_LSTM;
results = bayesopt(minfn, vars,'IsObjectiveDeterministic', false,...
    'AcquisitionFunctionName', 'expected-improvement-plus','MaxObjectiveEvaluations',200, 'NumSeedPoints',30);

opt_vars = bestPoint(results);
if contains(filename,"Italy")
    save(strcat("IT_best_LSTM",num2str(round(best_rmse*1000)),".mat"), 'Dataset', 'mu', 'sig', 'best_net', 'best_rmse', 'best_random_seed', 'best_vars')
elseif contains(filename,"Taiwan")
    save(strcat("TW_best_LSTM",num2str(round(best_rmse*10000)),".mat"), 'Dataset', 'mu', 'sig', 'best_net', 'best_rmse', 'best_random_seed', 'best_vars')
end

end

