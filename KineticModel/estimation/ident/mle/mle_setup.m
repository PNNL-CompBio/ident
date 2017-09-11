function prob = mle_setup(data)

if isfield(data,'pname')
    pname = data.pname;
end
if isfield(data,'casmodelfun')
    casfh = data.casmodelfun;
end
% if isfield(data,'integratorfun')
%     intfun = data.integratorfun;
% end
if isfield(data,'xinit')
    xinit = data.xinit;
end
if isfield(data,'yinit')
    yinit = data.yinit;
end 
if isfield(data,'tspan')
    tspan = data.tspan;
end
if isfield(data,'freq')
    freq = data.freq;
end
if isfield(data,'xexp')
    xexp = data.xexp;    
end
if isfield(data,'yexp')
    yexp = data.yexp;
end
npts = length(tspan)-1;
data.npts = npts;

if ~isfield(data,'ident_idx') && ~isempty(pname)    
    plist = {'K1ac','K3fdp','L3fdp','K3pep','K2pep',...
            'V4max','k1cat','V3max','V2max','acetate'}; 
    ident_idx = find(strcmpi(plist,pname));    
    data.ident_idx = ident_idx;
elseif ~isfield(data,'ident_idx') && isempty(pname)    
    error('No parameter chosen for identifiability analysis');
end   

% create CAS function with custom integrator of nlsq opt
[ode,flux,~,~,x,p,p_useless,acetate] = casfh(data.nc);
% [ode,~,~,fx,x,p] = kotte_CAS();

% RK4 integrator
dt = tspan(end)/npts;
k1 = ode(x,p,p_useless,acetate);
k2 = ode(x+dt/2.0*k1,p,p_useless,acetate);
k3 = ode(x+dt/2.0*k2,p,p_useless,acetate);
k4 = ode(x+dt*k3,p,p_useless,acetate);
xfinal = x+dt/6.0*(k1+2*k2+2*k3+k4);
yfinal = flux(xfinal,p,p_useless,acetate);

xstate_one_step =...
casadi.Function('xstate_one_step',{x,p,p_useless,acetate},{xfinal,yfinal});

[xstate,ystate] = xstate_one_step(x,p,p_useless,acetate);
xstate_onepoint =...
casadi.Function('xstate_onepoint',{x,p,p_useless,acetate},{xstate,ystate});
xstate_onepoint = xstate_onepoint.expand();
xdyn_fun = xstate_onepoint.mapaccum('all_samples',npts);

% intfun = str2func(intfun);
% [xdyn_fun,~,x,p,ident_c,p_useless,acetate] = intfun(casmodelf,data);
% p_all = [p(1:ident_idx-1);ident_c;p(ident_idx:end)]; % ;
p_fixed = [p_useless;acetate];

% final symbolic expression to be used during optimization
% [x_sym,y_sym] =...
% xdyn_fun(xinit,repmat(p,1,npts),repmat(data.odep(14:16)',1,npts),.1);
[x_sym,y_sym] =...
xdyn_fun(xinit,repmat(p,1,npts),repmat(p_useless,1,npts),acetate);

% add initial value
x_sym = [casadi.DM(xinit) x_sym];
y_sym = [casadi.DM(yinit) y_sym];

y_model_sym = y_sym([1 3 4 5],freq);
y_error = (yexp-y_model_sym);
y_error = sum(y_error,2);
obj = .5*dot(y_error,y_error);

% define obj as function to be used outside casadi implementation of ipopt
objfun = casadi.Function('objfun',{p,p_fixed,x},{obj});
objfh = @(x)full(objfun(x,data.odep(14:17)',xinit));
% input for jac fun is same as objfun (function whose jacobian is calculated)
gradfun = jacobian(objfun); % this generates a function for jacobian
gradfh = @(x)full(gradfun(x,data.odep(14:17)',xinit));

% bounds for mle estimate of all 13 parameters for given input (acetate)
[lb,ub] = ident_bounds_mle(length(p));
hessfun = [];

prob = struct('objfun',objfh,'grad',gradfh,'hess',hessfun,...
            'npts',npts,'xinit',xinit,'yinit',yinit,...
            'xexp',xexp,'yexp',yexp,...
            'lb',lb,'ub',ub);