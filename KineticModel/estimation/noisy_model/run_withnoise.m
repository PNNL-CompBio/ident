function [xdyn,fdyn,xss1,fss1,opts] = run_withnoise(tspan)
%% noisy stochastic model
% kinetic modeling with noisy metabolomics data 
% test using kotte model 
% algorithm :
% min |vmodel - vexpt|
%  st Svmodel = 0;
%     vmodel = f(x,p);
%     p >= pmin;
%     p <= pmax;
% given : x(expt), vexpt

% experimental data is generated through addition of noise to actual kotte model
% vmodel will use convenience kinetics for estimating fluxes

%% load original kotte model
if ~exist('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\Kotte2014\model\kotte_model.mat')
    status = 2;
    fprintf('\nLinux System\n');
else 
    status = 1;
    fprintf('\nWindows System\n');
end
if status == 1
    load('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\Kotte2014\model\kotte_model.mat');
elseif status == 2
    load('/home/shyam/Documents/Courses/CHE1125Project/IntegratedModels/KineticModel/Kotte2014/model/kotte_model.mat');    
end

pconv = [.1,.3,0]; % extra parameters for CK 'K1pep','K2fdp','rhoA'
p = [pvec,pconv];
p(9) = [];
ival = [M;pvec(9)];
clear pvec

%% solve noisy model using ode45
% odep = struct('p',p,'model',model);
odep = p;
solver_opts = odeset('RelTol',1e-3,'AbsTol',1e-3);
opts = struct('tspan',tspan,'x0',ival,'solver_opts',solver_opts,'odep',odep);

% % systems check
% noisy_model = @(t,x)simnoisyODE_kotte(t,x,odep);
% noisy_flux_test = noisyflux_kotte([M;model.PM],odep);

% simulate noisy system from random initial condition - this is better for
% simulating the noisy model
[xdyn,fdyn,xss1,fss1] = solve_ode(@simnoisyODE_kotte,opts,@kotte_flux_noCAS);

% solve noisy NLAE as a stochastic differential equation (SDE) with
% Euler-Maruyama algorithm
% options = sdeset('SDEType','Ito',...
%                  'RandSeed',2);
% g = @(t,y)[ones(3,1);0];             
% [xdyn,w] =...
% sde_euler(@(t,x)simnoisyODE_kotte(t,x,opts.odep),g,opts.tspan,opts.x0,options);
% xdyn = xdyn';


figure
subplot(211);
plot(tspan,xdyn);
ylabel('concentrations a.u.');
legend('pep','fdp','E','acetate');
subplot(212)
plot(tspan,fdyn);
ylabel('fluxes a.u.');
legend('J','E(FDP)','vFbP','vEX','vPEPout');