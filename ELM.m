function [opt_vars] = ELM(filename)

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

% Optimize
best_rmse = 1e06;
best_net = [];
best_random_seed=0;
best_vars=[];
% Define hyperparameters to optimize
vars = [optimizableVariable('timeWindows', [7,21], 'Type', 'integer');
    optimizableVariable('C', [10^(-4),10^(4)], 'Type', 'real');
    optimizableVariable('S', [100,2000], 'Type', 'integer')];

% Optimize
minfn = @performance_ELM;
results = bayesopt(minfn, vars,'IsObjectiveDeterministic', false,...
    'AcquisitionFunctionName', 'expected-improvement-plus','MaxObjectiveEvaluations',200, 'NumSeedPoints',10);

opt_vars = bestPoint(results);

if contains(filename,"Italy")
    save(strcat("IT_best_ELM",num2str(round(best_rmse*1000)),".mat"), 'Dataset', 'mu', 'sig', 'best_net', 'best_rmse', 'best_random_seed', 'best_vars')
elseif contains(filename,"Taiwan")
    save(strcat("TW_best_ELM",num2str(round(best_rmse*10000)),".mat"), 'Dataset', 'mu', 'sig', 'best_net', 'best_rmse', 'best_random_seed', 'best_vars')
end

end

