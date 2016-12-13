% continuation with shooting methods for 2 point BVPs
% 1. Agarwal, R., 1979
% 2. Shipman, J. S., and Roberts, S. M., 1967

% shooting method of Lance and Goodman
% variables
% nvar     - number of variables
% yiknwn    - rx1 variables for which initial conditions are given
% yfknwn    - (nvar-r)x1 variables for which terminal conditions are given
% yinit     - initial values (guesses and given)
% yterm     - terminal values (given values only)
% dely      - [delyi delyf]
% delyi     - difference between given and calculate initial conditions
%           - is 0 initially when strating at the first iteration
% delyf     - difference between given and calculated terminal conditions
% xic       - nx1 adjoint variables obtained from reverse integration of
%             adjoint equation
% xf        - nx1 adjoint variable initial conditions for reverse
%             integration


% define problem
% Holt.m
% initial conditions
nvar = 5;
yinit = zeros(nvar,1);

% known initial conditios @ t0
yiknwn = zeros(nvar,1);
yiknwn(1) = 1; yiknwn(2) = 1; yiknwn(4) = 1;
yiknwn = find(yiknwn);
r = length(yiknwn);
yiunkwn = setdiff(1:nvar,yiknwn);

% terminal conditions
yterm = zeros(nvar,1);
yterm(4) = 1;

% known terminal conditions @ tf
yfknwn = zeros(nvar,1);
yfknwn(2) = 1; yfknwn(4) = 1;
yfunkwn = find(~yfknwn);
yfknwn = find(yfknwn);

% guess unknown initial conditions
yinit(yiunkwn) = [-1;0.6];

% beginning of iterative loop
% assume dely(t0) = 0
delyi = getvaldiff(yinit,yinit);

% % integrate system with guessed/new intial conditions
% opts = odeset('RelTol',1e-12,'AbsTol',1e-10);
% [~,ydyn] = ode45(@HoltODE,0:0.1:3.5,yinit,opts);
% yf = ydyn(end,:)';
% 
% % check difference in final values
% % delyf = getvaldiff(yterm,yf); % assuming yf is obtained at tf
% delyf = zeros(nvar,1);

eps = 1e-6;
ti = 0;
tf = 3.5;

opts = odeset('RelTol',1e-12,'AbsTol',1e-10);
[yi,yf,delyf] =...
itershooting(@HoltODE,yinit,yterm,ti,tf,yiunkwn,yfknwn,delyi,[],[],opts);

[yi,yf,delyf] =...
execshooting(@HoltODE,yi,yf,ti,tf,yiunkwn,yfknwn,delyi,delyf,yf,eps);

% start of while loop for BVP shooting
% while abs(delyf(yfknwn)) > repmat(eps,length(yfknwn),1)
%     % run shooting iteration
%     delyf = itershooting(@HoltODE,yinit,yterm,ti,tf,yiunkwn,yfknwn,delyi,delyf,yf,opts);
% end





