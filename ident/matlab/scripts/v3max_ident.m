% identifiability analysis with ss data for V3max

%% load noisy data with MLE data
if ~exist('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel')
    status = 2;
    fprintf('\nLinux System\n');
else 
    status = 1;
    fprintf('\nWindows System\n');
end

if status == 1    
    load('C:/Users/shyam/Documents/Courses/CHE1125Project/IntegratedModels/KineticModel/estimation/ident/mle/mle_sep14');
elseif status == 2    
    load('~/Documents/Courses/CHE1125Project/IntegratedModels/KineticModel/estimation/ident/mle/mle_sep14');    
end

%% set PLE options
% collect only needed perturbations for analysis
% avail_pert = size(no_noise_sol,2);
% use_pert = 1;
% npert = length(use_pert);
% [exp_select_sol,no_noise_select_sol] = parseperturbations(no_noise_sol,use_pert);

% use wt as initial value for all perturbations
xinit = repmat(noisy_xss(:,1),npert,1);
yinit = repmat(noisy_fss(:,1),npert,1);

freq = 1:1:3001;
ynoise_var = .01;

optim_opts = struct('pname','V3max','nc',3,'nf',6,'npert',npert,...                    
                    'plim',[0.001 6],...
                    'minmax_step',[1e-6 .2],...
                    'casmodelfun',@kotteCASident_pert,...
                    'integratorfun','RK4integrator_cas',...
                    'odep',odep_bkp,...
                    'tspan',opts.tspan,...
                    'freq',freq,...
                    'x0',noisy_xss(:,1),...
                    'xinit',xinit,...
                    'yinit',yinit,...
                    'xexp',exp_select_sol.xdyn(:,freq),...
                    'yexp',exp_select_sol.fdyn([1 3 4 5],freq),...
                    'ynoise_var',ynoise_var);

% set confidence interval threshold for PLE 
alpha = .90; % alpha quantile for chi2 distribution
dof = 12; % degrees of freedom
% chi2 alpha quantile
delta_alpha_1 = chi2inv(alpha,1);      
delta_alpha_all = chi2inv(alpha,dof);
thetai_fixed_value = MLE_noisy.mle_pval(12);
theta_step = 0;

% loop all the abopve statements for complete identifiability algforithm
maxiter = 1000;

% initial value for optimization
scale = ones(8,1);

% p0 for K1ac
% scale(2) = 1e6;
% p0 = opts.odep(2:13)'./scale;

% p0 for k1cat
scale(3) = 1e6;
p0 = [opts.odep(1:5)';opts.odep(10:11)';opts.odep(13)']./scale;

%% call PLE evaluation function
pos_neg = [1 3];
nid = length(pos_neg);
PLEvals = cell(nid,1);
parfor id = 1:nid
    PLEvals{id} =...
    getPLE(thetai_fixed_value,theta_step,p0,opts.odep,...
           delta_alpha_1,optim_opts,maxiter,pos_neg(id));             
end

%% collect data and plot from parallel estimation
PLE_unify = unifyPLEres(PLEvals);
plotPLE(PLE_unify,delta_alpha_1,delta_alpha_all);  



