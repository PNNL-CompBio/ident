% continuation for 2 point BVP
% define problem
% Holt.m
% initial conditions
nvar = 5;
yinit = zeros(nvar,1);

% known initial conditios @ t0
yiknwn = zeros(nvar,1);
yiknwn(1) = 1; yiknwn(2) = 1; yiknwn(4) = 1;
% known terminal conditions @ tf
yterm = zeros(nvar,1);
yterm(4) = 1;

yiknwn = find(yiknwn);
r = length(yiknwn);
yiunkwn = setdiff(1:nvar,yiknwn);

% terminal conditions @ tf
yfknwn = zeros(nvar,1);
yfknwn(2) = 1; yfknwn(4) = 1;
yfunkwn = find(~yfknwn);
yfknwn = find(yfknwn);

% choose unknown initial conditions
yinit(yiunkwn) = [-1;0.6];

% cotinuation parameters
F = 1.0; 
tau = 0.1;
ti = 0;
tf = 3.5;
tterm = 11.0;
eps = 1e-6;

while tf<tterm
    flag = 1;
    while flag
        % integrate till time t1 till which there are no numerical problems
        opts = odeset('RelTol',1e-12,'AbsTol',1e-10);
        [yi,yf,delyf] =...
        itershooting(@HoltODE,yinit,yterm,ti,tf,yiunkwn,yfknwn,delyi,[],[],opts);
        
        % solve 2 point bvp over (t0,t1) using goodman lance method
        [yi,yf,delyf,flag] =...
        execshooting(@HoltODE,yi,yf,ti,tf,yiunkwn,yfknwn,delyi,delyf,yf,eps);
    
        if flag
            tf = tf + tau;
        end        
    end
    tau = tau/2;
end





% extend time interval from (t0,t1) to (t0,t2)