% estimationn script - simultaneous ss estimation of fluxes, concenrations
% and parameters
% or load pre-calculated data
load('C:/Users/shyam/Documents/Courses/CHE1125Project/IntegratedModels/KineticModel/estimation/noisy_model/pdata_aug24');

nc = 3;
nf = 6;
npert = 4;
np = 13;
nvar = nc*npert+np+nf*npert+2;

xexp = exp_sol{1}.xss;
vexp = exp_sol{1}.fss;
xexp = reshape(xexp,[nc*npert,1]);
vexp = reshape(vexp,[nf*npert,1]);

% sym obj
[obj,var,par,x,p,flux,vareps,p_usl,ac,wts] =...
kotte_pest_allf_obj(xexp,vexp,nc,nf,npert);
% sym cons
cons =...
kotte_pest_allf_cons(xexp,vexp,nc,nf,npert,x,p,flux,vareps,p_usl,ac);
ncons = size(cons,1);
consfun = casadi.Function('consfun',{var,par},{cons});

% get parameters
p0_obj = odep_bkp(1:13)';
scale = ones(np,1);
scale(3) = 1e-6;

weigths = [1000;1;1;100];
p0_const = odep_bkp(14:end)';
par_val = [p0_const;weigths];

% get initial value
xval = [xexp;p0_obj.*scale;vexp].*(1+.1);
x0 = [xval;0;0];
cons_check = full(consfun(x0,par_val));

% set bounds for x0
lb = zeros(nvar,1);
ub = zeros(nvar,1);
% conc
lb(1:nc*npert) = 1e-7;
ub(1:nc*npert) = 300;
% parameters
[p_bounds_lb,p_bounds_ub] = p_bounds();
lb(nc*npert+1:nc*npert+np) = p_bounds_lb;
ub(nc*npert+1:nc*npert+np) = p_bounds_ub;
% fluxes
lb(nc*npert+np+1:nc*npert+np+nf*npert) = 0;
ub(nc*npert+np+1:nc*npert+np+nf*npert) = 20;
% uncertainty
lb(nvar-2+1:nvar-1) = 0;
ub(nvar-2+1:nvar-1) = 1;
lb(nvar-1+1:nvar) = 0;
ub(nvar-1+1:nvar) = 1;
% set bounds for cons
lbg = ones(ncons,1);
ubg = ones(ncons,1);
% ss cons bounds (=)
lbg(1:nc*npert) = 0;
ubg(1:nc*npert) = 0;
% nl flux cons (=)
lbg(nc*npert+1:nc*npert+nf*npert) = 0;
ubg(nc*npert+1:nc*npert+nf*npert) = 0;
% nl noisy conc cons (<=)
lbg(nc*npert+nf*npert+1:nc*npert+nf*npert+2*nc*npert) = -Inf;
ubg(nc*npert+nf*npert+1:nc*npert+nf*npert+2*nc*npert) = 0;
% nl noisy flux cons (<=)
lbg(nc*npert+nf*npert+2*nc*npert+1:nc*npert+nf*npert+2*nc*npert+2*nf*npert) = -Inf;
ubg(nc*npert+nf*npert+2*nc*npert+1:nc*npert+nf*npert+2*nc*npert+2*nf*npert) = 0;

estprob = struct('x',var,'f',obj,'g',cons,'p',par);
options.ipopt.fixed_variable_treatment = 'make_constraint';
solver = casadi.nlpsol('solver','ipopt',estprob,options);
sol = solver('x0',x0,'p',par_val,'lbx',lb,'ubx',ub,'lbg',lbg,'ubg',ubg);

xopt = full(sol.x);


% x = casadi.SX.sym('x',1);
% y = casadi.SX.sym('y',1);
% nlp = struct('x',[x;y],'f',x/y);
% options.warn_initial_bounds = 1;
% NLP = casadi.nlpsol('solver','ipopt',nlp,options);
% sol = NLP('x0',[.1 .1],'lbx',[.001 .001],'ubx',[10 10]);
% int = struct('x',x,'ode',exp(-x));
% opt.grid = 0:.1:20;
% F = casadi.integrator('F','cvodes',int,opts);




