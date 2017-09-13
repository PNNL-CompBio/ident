function noisy_ss = addnoise_wrapper(pt_sol_id,solstruct)

nptsol = length(pt_sol_id);
noisy_ss = struct([]);
for j = 1:nptsol
    xss = solstruct(pt_sol_id(j)).xss;
    fss = solstruct(pt_sol_id(j)).fss;
%     pt_p = solstruct(pt_sol_id(j)).odep;    
    [noisy_xss,noisy_fss] = addnoise(xss,fss);
    noisy_ss(j).xss = noisy_xss;
    noisy_ss(j).fss = noisy_fss;
    if isfield(solstruct,'xdyn')
        noisy_xdyn = addnoise(solstruct(pt_sol_id(j)).xdyn);
        noisy_ss(j).xdyn = noisy_xdyn;
    end
    if isfield(solstruct,'fdyn')
        [~,noisy_fdyn] = addnoise([],solstruct(pt_sol_id(j)).fdyn);
        noisy_ss(j).fdyn = noisy_fdyn;
    end
end