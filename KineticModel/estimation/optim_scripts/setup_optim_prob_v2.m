% setup optimization problem such that all perturbation values are used and
% determnined as variables of the problem
function [prob,newdata] = setup_optim_prob_v2(optimdata)

if isfield(optimdata,'flxid')
    flxid = optimdata.flxid;
end

% all parameters available
rxn_plist = {{'K1ac', 'k1cat'},{},{'K3fdp','K3pep','V3max'},{'K2pep','V2max'},...
              {'V4max'},{}};
relevant_list = rxn_plist{flxid};       
% all parameters available (ordered)
plist = {'K1ac','K3fdp','L3fdp','K3pep','K2pep','vemax','KeFDP','ne',...
        'd','V4max','k1cat','V3max','V2max','K1pep','K2fdp','rhoA','acetate'};        
% find relevant parametyers in ordered list for id
if ~isempty(relevant_list)
    p_id = cellfun(@(x)strcmpi(x,plist),relevant_list,'UniformOutput',false);
    p_id = cellfun(@(x)find(x),p_id);
else    
    error('No parameters to estimate');
end
if isfield(optimdata,'nc')
    nc = optimdata.nc;
end
if isfield(optimdata,'nf')
    nf = optimdata.nf;
end
if isfield(optimdata,'vexp')
    vss_exp = optimdata.vexp(flxid,:);    
end
if isfield(optimdata,'xexp')
    xss_exp = optimdata.xexp;
end
npert = size(xss_exp,2);
vss_exp_v = reshape(vss_exp,[nf*npert,1]);
xss_exp_v = reshape(xss_exp,[nc*npert,1]);

% determine nvar
nvar = nc*npert+nf*npert+length(p_id);
newdata = optimdata;
newdata.vexp = vss_exp_v;
newdata.xexp = xss_exp_v;
newdata.npert = npert;
newdata.nvar = nvar;
newdata.p_id = p_id;

% setup bounds
if isfield(optimdata,'lb')
    lb = optimdata.lb;
else
    lb = zeros(nvar,1);
end
if isfield(optimdata,'ub')
    ub = optimdata.ub;
else
    ub = zeros(nvar,1);
end
% if isfield(optimdata,'wt_xss')
%     exp_xss  = optimdata.wt_xss;
% end
% if isfield(optimdata,'wt_fss')
%     exp_fss = optimdata.wt_fss;
% end
if isfield(optimdata,'eps')
    eps = optimdata.eps;
end
% set bounds - concentration
lb(1:nc*npert) = xss_exp_v.*(1-eps);
ub(1:nc*npert) = xss_exp_v.*(1+eps);
% set bounds - parameter
lb(nc*npert+1:nc*npert+length(p_id)) = .05*ones(length(p_id),1); 
ub(nc*npert+1:nc*npert+length(p_id)) = 10*ones(length(p_id),1);
% set bounds - flux
lb(nvar-nf*npert+1:nvar) = vss_exp_v*(1-eps);
ub(nvar-nf*npert+1:nvar) = vss_exp_v*(1+eps);

% setup objectives and cons
if isfield(optimdata,'obj')
    objhs = optimdata.obj;
end
if isfield(optimdata,'nlcons')
    conshs = optimdata.nlcons;
end
if isfield(optimdata,'nlrhs')
    rhsval = optimdata.nlrhs;
else
    rhsval = [];
end
if isfield(optimdata,'nle')
    nles = optimdata.nle;
else
    nles = [];
end

newdata = rmfield(newdata,{'obj','nlcons','nlrhs','nle'});

% choose obj and cons
fhobj = str2func(objhs{flxid});
obj = @(x)fhobj(x,newdata.odep,newdata);
newdata.obj = obj;

fhcons = str2func(conshs{flxid});
nlcons = @(x)fhcons(x,newdata.odep,newdata);
newdata.nlcons = nlcons;

if ~isempty(rhsval{flxid})
    nlrhs = rhsval{flxid};
else
    nlrhs = zeros(npert,1);
end
newdata.nlrhs = nlrhs;
if ~isempty(nles{flxid})
    nle = nles{flxid};
else
    nle = zeros(npert,1);
end
newdata.nle = nle;

% setup problem structure
prob =...
struct('obj',obj,'nlcons',nlcons,'nlrhs',nlrhs,'nle',nle,'lb',lb,'ub',ub);


