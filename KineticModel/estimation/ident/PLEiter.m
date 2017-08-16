function [optsol,thetai_fixed_value,theta_step,obj_new,iter_theta_step] =...
        PLEiter(thetai_fixed_value,theta_step,xval,p_val,PLE_threshold,setup_opts)
    
% new theta
thetai_fixed_value = thetai_fixed_value + theta_step;

% PLE through optimization for new thetai
prob_cas = identopt_setup(setup_opts,thetai_fixed_value);
optsol = solve_nlsqopt(prob_cas,xval);

% adpative step in thetai
[theta_step,obj_new,iter_theta_step] =...
adaptive_step(optsol.fval,optsol.xval,prob_cas,p_val,thetai_fixed_value,PLE_threshold);
    
    