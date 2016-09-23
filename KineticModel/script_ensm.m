% kinetic ensemble modeling script any/all models
% testing with Kotte model of glucoeneogenesis
addpath(genpath('C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel'));
% rxfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\data\gtoy1.txt';
% cnfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\data\gtoy1C.txt';
% rxfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\data\gtoy2.txt';
% cnfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\data\gtoy2C.txt';
rxfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\data\gtoy9.txt';
cnfname = 'C:\Users\shyam\Documents\Courses\CHE1125Project\IntegratedModels\KineticModel\data\gtoy9C.txt';
% create model structure
[model,parameter,variable,nrxn,nmetab] = modelgen(rxfname);

% obtain conentrations from file
[mc,model,met] = readCNCfromFile(cnfname,model);

% FBA or pFBA solution - optional
% fix flux uptakes for FBA solution
% Vup_struct.exAC = 20;%mmol/gDCW.h
Vupstruct.ACex = 20;
Vupstruct.ENZ1ex = 1;

% designate reactions for which uptake should not be zero in FBA
% ess_rxn = {'exH','exPI','exAC'};
essrxn = {'ACex','exH','exH2O'};

% assign initial fluxes and calculate FBA fluxes for direction
% FBAmodel.bmrxn = 14;
% model.bmrxn = 34;
model = FBAfluxes(model,'pfba',essrxn,Vupstruct,...
                     find(strcmpi(model.rxns,'G6Pt2r')));

rxnadd = {};

% dilution rate in model in h-1;
model.D = 0.8;

% metabolites that do not affect thermodynamic equilibrium  
he = find(strcmpi(model.mets,'h[e]'));
hc = find(strcmpi(model.mets,'h[c]'));
h2oc = find(strcmpi(model.mets,'h2o[c]'));
h2oe = find(strcmpi(model.mets,'h2o[e]'));
model.remid = [he hc h2oc h2oe];

% sample initial metabolite concentrations for estimating kinetic parameters
[mc,parameter,smp] = parallel_sampling(model,parameter,'setupMetLP_gtoy',met,mc,rxnadd);
if isempty(mc)
    % multiple saples are being supplied
    mc = smp{1,1};
    parameter = smp{1,2};
end

% get parameter estimates - estimate kinetic parameters in an ensemble
rxnadd = {};
rxnexcep = {'Ht2r'};

% FBAmodel.bmrxn = [];
[ensb,mc] = parallel_ensemble(model,mc,parameter,rxnadd,rxnexcep,1);

% serially solve ODE of model to steady state
model.rxn_add = rxnadd;
model.rxn_excep = rxnexcep;

% setup model for integration 
[newmodel,newpvec,Nimc,solverP,flux,dXdt] =...
setupKineticODE(model,ensb,mc,essrxn,Vupstruct,1000);

% get jacobian and eigen values and eigne vectors
% [J,lambda,w] = getjacobian(Nimc,newpvec,newmodel);

% solve only if models are feasible
if size(ensb,2)>1
    [outsol,~,allxeq,allfeq,allJac,alllambda] =...
    solveAllpvec(newmodel,newpvec,Nimc,solverP);
else
    if newpvec.feasible    
        % integrate model
        [outsol,~,allxeq,allfeq] = callODEsolver(newmodel,newpvec,Nimc,solverP);
        
        % get jacobian and eigen values and eigne vectors for new ss
        [J,lambda,w] = getjacobian(allxeq,newpvec,newmodel);
    else
        error('No feasible model found');
    end
end

% time course plots
AllTimeCoursePlots(outsol,newmodel,{'pyr[c]','pep[c]','fdp[c]','ac[c]','ac[e]','biomass[e]'},...
                                   {'ACt2r','FBP','ICL','MALS','G6Pt2r','ACex'});

% perturbations to steady states  
[outsol,allxss,allfss] = perturbation(allxeq,newmodel,newpvec,solverP,[1:3,5:14],10);



