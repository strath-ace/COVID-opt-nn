function [] = optimise_gov_measuresIT()

global filename_dataset
global filename_model
global Tmax

filename_model ='IT_best.mat';
filename_dataset = 'COVIDItalyMATLAB_extended.csv';


xLast = []; % Last place computeall was called
myf = []; % Use for objective at xLast
myc = []; % Use for nonlinear inequality constraint
myceq = [];
fun = @objfun; % the objective function, nested below
cfun = @constr; % the constraint function, nested below
iter = 1;
vals = [];
fvals = [];

Tmax = 76;


%% DATA preparation
Dataset = readtable(filename_dataset);
Dataset = Dataset{:,:};

n_opt_vars = 27;
bounds = zeros(n_opt_vars,2);
bounds(1,:) = [1 20]; bounds(2,:) = [5 25]; bounds(3,:) = [20 76];
bounds(4,:) = [15 50]; bounds(5,:) = [-14 14];
bounds(6,:) = [20,50];
bounds(7,:) = [1,10]; bounds(8:11,:) = [1,30].*ones(4,2);
bounds(12,:) = [20,40]; bounds(13:19,:) = [1,30].*ones(7,2);
bounds(20,:) = [15,50]; bounds(21,:) = [-14,14];
bounds(22,:) = [15,50]; bounds(23,:) = [-14,14];
bounds(24,:) = [15,50]; bounds(25,:) = [-14,14];
bounds(26,:) = [15,50]; bounds(27,:) = [-14,14];


LB = bounds(:,1);
UB = bounds(:,2);

load('IT_res_optF6_FINAL.mat','output')
stream = RandStream.getGlobalStream;
stream.State = output.rngstate.State;

options = optimoptions(@ga,'MaxGenerations', 1000, 'PlotFcn', 'gaplotbestf', ...
    'MaxStallGenerations',100,'FunctionTolerance',1e-10,'PopulationSize',100);%, 'NonlinearConstraintAlgorithm', 'penalty');
[x,fval,exitflag,output,population,scores]  = ga(fun,n_opt_vars,[],[],[],[],LB,UB,cfun,[1:n_opt_vars],options);

    function y = objfun(x)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc, myceq] = performance_SA(x);
            xLast = x;
        end
        vals(iter,:) = x;
        fvals(iter,1) = myf;
        iter = iter+1;
        % Now compute objective function
        y = myf;
    end

    function [c,ceq] = constr(x)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc, myceq] = performance_SA(x);
            xLast = x;
        end
        % Now compute constraint functions
        c = myc; % In this case, the computation is trivial
        ceq = myceq;
    end


save 'IT_res_opt.mat'


end

