% optimization of flux parameters in kotte model for a CK formulation
function [x_opt,opt_id,new_opt_p,fval] =...
        flux1_k_noisy(opts,xss2,fss2,plist,old_opt_p)
if nargin<5
    old_opt_p = [];
end    

% flux 1    
p_id = cellfun(@(x)strcmpi(plist,x),{'K1ac','k1cat'},'UniformOutput',false);
p_id = cellfun(@(x)find(x),p_id);
p = opts.odep(p_id)';
% p = [.1;.1];

x0 = [xss2;p];
% steady state experimental concetrations and fluxes needed for constraints
% fed as parameters
% f2 = ; % add steayd state experimental flux
optim_p = [xss2;fss2(1,:);.2]; % [concentrations(expt);flux(expt);e(init val)]

% all concentrations as well as kientic parameters are variables
% lb = [pep;fdp;e;ac] - acetate is a equality constraint (fixed parameter)
lb = [0;0;0;xss2(4,1);1e-3;1e-3]; 
ub = [20;20;20;xss2(4,1);10;10];
[x_opt,fval,~,~,opts] =...
nlconstoptim_flux(opts,[],lb,ub,x0,optim_p,0,@contr_flux1_noisy); % linear objective

% check flux using conkin rate law
if ~isempty(old_opt_p)
    opts.odep = old_opt_p;
% else
%     pconv = [.1;.3;0]; % extra parameters for CK 'K1pep','K2fdp','rhoA'
%     opts.odep = [opts.odep';pconv];
end
opt_id = p_id; % [p_id,14];
opts.odep(opt_id) = x_opt;
new_opt_p = opts.odep;
