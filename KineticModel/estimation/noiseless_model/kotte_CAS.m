function [FX,dfx_sym,D2FX,fx_sym,x,p,FX_flux] = kotte_CAS()

x = casadi.SX.sym('x',3,1);
p = casadi.SX.sym('p',17,1);

fx_sym = cell(3,1);

% parameters
% d = p(9);

flux = kotte_flux_CAS(x,p);
% PEP
fx_sym{1} = flux{1} - flux{4} - flux{5};
% FBP
fx_sym{2} = flux{4} - flux{3};
% enzymes
% E
fx_sym{3} = flux{2} - flux{6};
% acetate
% fx_sym{4} = x(4) - x(4);


FX = casadi.Function('FX',{x,p},{[fx_sym{1};...
                                  fx_sym{2};...
                                  fx_sym{3}]});
                              
FX_flux = casadi.Function('FX_flux',{x,p},{[flux{1};...
                                            flux{2};...
                                            flux{3};...
                                            flux{4};...
                                            flux{5};...
                                            flux{6}]});
                                        
dfx_sym = jacobian([fx_sym{:}],x);
D2FX = [];
                                        