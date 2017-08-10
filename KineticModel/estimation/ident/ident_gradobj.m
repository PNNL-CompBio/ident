% gradient of weighted nlsq objective using sensitivity coeffiecients from
% solving model ode+parameter variational equations
function gradobj = ident_gradobj(x,data)

if isfield(data,'odep')
    p = data.odep;
end
if isfield(data,'idx')
    idx = data.idx;
end
if isfield(data,'xexp_dyn')
    yexp = data.xexp_dyn;
end
if isfield(data,'xexp_var')
    yexp_var = data.xexp_var;
end
if isfield(data,'nvar')
    nvar = data.nvar;
end
if isfield(data,'np')
    np = data.np;
end
% function to solve ode and variational equations simultaneously using
% casadi
if isfield(data,'modelsensf')
    modelsensf = data.modelsensf;
end
% if isfield(data,'gradobj')
%     gradobjfh = data.gradobj;
% end


% augment parameter vector with fixed parameter vector value
aug_p = [x(1:idx-1) p(idx) x(idx:end)];

% calculate sensitivity by solving augmented system
yres = modelsensf(aug_p);
ymodel = yres(1:nvar,:);
ysens = yres(nvar+1:end,:);
sens_mat = reshape(ysens,[nvar,np]);
sens_mat_copy = sens_mat;
sens_mat_copy(:,idx) = [];

premul = -2.*((yexp-ymodel)./yexp_var);





