% identifiability analysis with ss data for V2max

%% load noise free data
if ~exist('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel')
    status = 2;
    fprintf('\nLinux System\n');
else 
    status = 1;
    fprintf('\nWindows System\n');
end

if status == 1    
    load('C:/Users/shyam/Documents/Courses/CHE1125Project/IntegratedModels/KineticModel/estimation/noiseless_model/pdata_nn_sep1');
elseif status == 2    
    load('~/Documents/Courses/CHE1125Project/IntegratedModels/KineticModel/estimation/noiseless_model/pdata_nn_sep1');    
end

%% set PLE options
% collect only needed perturbations for analysis
avail_pert = size(no_noise_sol,2);
use_pert = [1 2 3 avail_pert];
npert = length(use_pert);
[exp_select_sol,no_noise_select_sol] = parseperturbations(no_noise_sol,use_pert);

% use wt as initial value for all perturbations
xinit = repmat(exp_select_sol.xss(:,end),npert,1);



freq = 1:200:3001;
optim_opts = struct('pname','V2max','nc',3,'nf',6,'npert',npert,...
                    'nunpert',10,...
                    'plim',[0.001 6],...
                    'casmodelfun',@kotteCASident_pert,...
                    'integratorfun','RK4integrator_cas',...
                    'odep',odep_bkp,...
                    'tspan',opts.tspan,...
                    'freq',freq,...
                    'x0',xss,...
                    'xinit',xinit,...
                    'xexp',exp_select_sol.xdyn(:,freq),...
                    'p_pert',exp_select_sol.p_pert,...
                    'p_pert_logical',exp_select_sol.p_pert_logical,...
                    'objfun',@identobj);

% set confidence interval threshold for PLE 
alpha = .90; % alpha quantile for chi2 distribution
dof = 1; % degrees of freedom
% chi2 alpha quantile
delta_alpha = chi2inv(alpha,dof);      
thetai_fixed_value = .1;
theta_step = 0;

% loop all the abopve statements for complete identifiability algforithm
maxiter = 1000;

% initial value for optimization
scale = ones(10,1);

% p0 for K1ac
% scale(2) = 1e6;
% p0 = opts.odep(2:13)'./scale;

% p0 for V2max
scale(3) = 1e6;
p_unch = opts.odep(1:10)'./scale;
% p_pert = [opts.odep(11:13)';opts.odep(11:13)'];
p_pert = [2;.1;1;1];
p0 = [p_unch;p_pert];

[prob_struct,data] = identopt_setup_v2(optim_opts,1);
% solver_opts = ipoptset('max_cpu_time',1e8);
opts = optiset('solver','ipopt',...
              'maxiter',10000,...
              'maxfeval',500000,...
              'tolrfun',1e-6,...
              'tolafun',1e-6,...
              'display','iter',...
              'maxtime',3000);  
% test obj
objval = prob_struct.objfun(p0);
prob =...
opti('obj',prob_struct.objfun,'bounds',prob_struct.lb,prob_struct.ub,'options',opts);  
[xval,fval,exitflag,info] = solve(prob,p0); 
%% call PLE evaluation function
[PLEvals] =...
getPLE(thetai_fixed_value,theta_step,p0,opts.odep,delta_alpha,optim_opts,maxiter,2);
                
%%    



