function [] = optimise_gov_measuresTW()

global filename_dataset
global filename_model
global Tmax

filename_model ='TW_best.mat';
filename_dataset = 'COVIDTaiwanMATLAB_extended.csv';

xLast = []; % Last place computeall was called
myf = []; % Use for objective at xLast
myc = []; % Use for nonlinear inequality constraint
myceq = [];
fun = @objfun; % the objective function, nested below
cfun = @constr; % the constraint function, nested below

Tmax = 76;


%% DATA preparation
Dataset = readtable(filename_dataset);
Dataset = Dataset{:,:};

n_opt_vars = 54;
bounds = zeros(n_opt_vars,2);
bounds(1,:) = [1 3]; bounds(2,:) = [1 5]; bounds(3,:) = [1 5]; bounds(4,:) = [1 9]; bounds(5,:) = [24 44]; bounds(6,:) = [48 68]; bounds(7,:) = [31 51]; bounds(8,:) = [25 45]; bounds(9,:) = [27 47]; bounds(10,:) = [36 56]; bounds(11,:) = [43 63]; bounds(12,:) = [40 60];
bounds(13,:) = [1 20]; bounds(14:19,:) = [1,50].*ones(6,2);
bounds(20,:) = [30,60];
bounds(21,:) = [1,20]; bounds(22:28,:) = [1,50].*ones(7,2);
bounds(29,:) = [1,20]; bounds(30:46,:) = [1,30].*ones(17,2);
bounds(47,:) = [15,70]; bounds(48,:) = [-14,14];
bounds(49,:) = [15,70]; bounds(50,:) = [-14,14];
bounds(51,:) = [15,70]; bounds(52,:) = [-14,14];
bounds(53,:) = [15,70]; bounds(54,:) = [-14,14];


LB = bounds(:,1);
UB = bounds(:,2);

options = optimoptions(@ga,'MaxGenerations', 1000, 'PlotFcn', 'gaplotbestf', ...
    'MaxStallGenerations',100,'FunctionTolerance',1e-10,'PopulationSize',100);%, 'NonlinearConstraintAlgorithm', 'penalty');
[x,fval,exitflag,output,population,scores]  = ga(fun,n_opt_vars,[],[],[],[],LB,UB,cfun,[1:n_opt_vars],options);

    function y = objfun(x)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc, myceq] = performance_SA(x);
            xLast = x;
        end
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


save 'TW_res_opt.mat'


end
