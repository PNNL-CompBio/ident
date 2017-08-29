% add noise to input data and calculate corresponding noisy flux
function [noisy_xss,noisy_fss] = addnoise(x,p)

nvar = size(x,1);
nsmp = size(x,2);
% npar = size(p,1);
% no_noise_flux = zeros(size(kotte_flux_noCAS(x,p(1,:)),1),nsmp);
% for i = 1:npar
no_noise_flux = kotte_flux_noCAS(x,p);
nflx = size(no_noise_flux,1);
% end
% nflx = size(no_noise_flux,1);

if nsmp>1    
    pd = makedist('Uniform','lower',-.05,'upper',.05);    
else
    pd = makedist('Uniform','lower',-.05,'upper',.05);    
end
met_noise = random(pd,nvar,nsmp);
noisy_xss = x.*(1+met_noise);

% additive noise on flux
flux_noise = random(pd,nflx,nsmp);
noisy_fss = no_noise_flux.*(1+flux_noise);
% noisy_fss = [];

% nonlinear noise on flux from concentration
% if npar>1
%     noisy_fss = zeros(nflx,npar);
%     for i = 1:npar
%         noisy_fss(:,i) = kotte_flux_noCAS(noisy_xss(:,i),p(i,:));
%     end
% else
%     noisy_fss = kotte_flux_noCAS(noisy_xss,p);
% end

