function [obj,var,par,x,p,flux,vareps,p_usl,ac,wts,ss_obj] =...
        kotte_pest_allf_obj(xexp,vexp,nc,nf,npert)
x = casadi.SX.sym('x',nc*npert,1);
p = casadi.SX.sym('p',13,1);
p_usl = casadi.SX.sym('p_usl',3,1);
ac = casadi.SX.sym('ac',1,1);
flux = casadi.SX.sym('flux',nf*npert,1);
vareps = casadi.SX.sym('vareps',2,1);
wts = casadi.SX.sym('wts',4,1);

p_all = [p;p_usl;ac];

% parameters
% K1ac = p_all(1);    % or 0.02
% K3fdp = p_all(2);
% L3fdp = p_all(3)*1e6;
% K3pep = p_all(4);
% K2pep = p_all(5);
% vemax = p_all(6);        % for bifurcation analysis: 0.7:0.1:1.3
% KeFDP = p_all(7);        % or 0.45
% ne = p_all(8);             % or 2
% d = p_all(9);
% V4max = p_all(10);
% k1cat = p_all(11);   
% V3max = p_all(12);    
% V2max = p_all(13);   
ac = p_all(17);

% fx1 = k1cat.*x(3:nc:nc*npert).*ac - flux(1:nf:nf*npert).*(ac+K1ac);
% fx2 = -vemax + (vemax - flux(2:nf:nf*npert)).*(1+(KeFDP./x(2:nc:nc*npert)).^ne);
% ratio = 1+x(2:nc:nc*npert)./K3fdp;
% fx3 = V3max.*(ratio-1).*(ratio).^3 -...
%       flux(3:nf:nf*npert).*(ratio.^4+L3fdp.*(1+x(1:nc:nc*npert)./K3pep).^(-4));
% fx4 = V2max.*x(1:nc:nc*npert) - flux(4:nf:nf*npert).*(x(1:nc:nc*npert)+K2pep);
% fx5 = V4max.*x(1:nc:nc*npert) - flux(5:nf:nf*npert);
% fx6 = d.*x(3:nc:nc*npert)-flux(6:nf:nf*npert);

vmodel = flux;

v_error = vexp-vmodel;
v_norm = .5*dot(v_error,v_error);
x_error = xexp-x;
x_norm = .5*dot(x_error,x_error);

var = [x;p;flux;vareps];
par = [p_usl;ac;wts];

ss_obj = [];

obj = wts(1)*v_norm + wts(2)*x_norm + wts(3)*vareps(1) + wts(4)*vareps(2);

