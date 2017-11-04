% optimization of flux parameters in kotte model for a CK formulation
function [x_opt,opt_pid,new_opt_p,fval] =...
        flux3_k_scip(opts,xss2,fss2,plist,old_opt_p)
if nargin<5
    old_opt_p = [];
end
    
% flux 3 
p_id = cellfun(@(x)strcmpi(plist,x),{'K3pep','V3max','K3fdp','L3fdp'},'UniformOutput',false);
p_id = cellfun(@(x)find(x),p_id);
p = opts.odep(p_id)'; % [.1;.5;.1;3e6]; % % %  % 

f3 = fss2(3); % add steayd state experimental flux
optim_p = [xss2;f3]; % concentrations & fluxes (expt) are parameters
lb = [1e-6;1e-3;1e-6;1];
ub = [20;5;20;5e6];
[x_opt,fval,~,~,opts] = sciptest(opts,@scip_obj_3,lb,ub,p,optim_p);

% check flux using conkin rate law
if ~isempty(old_opt_p)
    opts.odep = old_opt_p;
% else
%     pconv = [.1;.3;0]; % extra parameters for CK 'K1pep','K2fdp','rhoA'
%     opts.odep = [opts.odep';pconv];
end
opt_pid = p_id; % [p_id,16];
opts.odep(opt_pid) = x_opt;
new_opt_p = opts.odep;
