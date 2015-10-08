function pvec = findVmax(model,pvec,mc)
bmr = model.bmrxn;
Vuptake = model.Vuptake;
S = -model.S(:,bmr);
mu = 0.1;

%indices - fluxes
vglc = strcmpi(model.rxns,'exGLC');
vpts = strcmpi(model.rxns,'glcpts');
vpgi = strcmpi(model.rxns,'pgi');
vg6pd = strcmpi(model.rxns,'g6pdh2r');
vpgl = strcmpi(model.rxns,'pgl');
vgnd = strcmpi(model.rxns,'gnd');
vtkt1 = strcmpi(model.rxns,'tkt1');
vtkt2 = strcmpi(model.rxns,'tkt2');
vtala = strcmpi(model.rxns,'tala');
vrpi = strcmpi(model.rxns,'rpi');
vrpe = strcmpi(model.rxns,'rpe');
vpfk = strcmpi(model.rxns,'pfk');
vfba = strcmpi(model.rxns,'fba');
vtpi = strcmpi(model.rxns,'tpi');
vgapd = strcmpi(model.rxns,'gapd');
vpgk = strcmpi(model.rxns,'pgk');
vpgm = strcmpi(model.rxns,'pgm');
veno = strcmpi(model.rxns,'eno');
vppc = strcmpi(model.rxns,'ppc');
vpdh = strcmpi(model.rxns,'pdh');
vack = strcmpi(model.rxns,'ackr');
vpta = strcmpi(model.rxns,'ptar');
vcs = strcmpi(model.rxns,'cs');
vacont = strcmpi(model.rxns,'aconta');
vicd = strcmpi(model.rxns,'icdhyr');
vakgd = strcmpi(model.rxns,'akgdh');
vsuca = strcmpi(model.rxns,'sucoas');
vfum = strcmpi(model.rxns,'fum');
vmdh = strcmpi(model.rxns,'mdh');

g6p = strcmpi(model.mets,'g6p[c]');
pgl = strcmpi(model.mets,'6pgl[c]');
pgc = strcmpi(model.mets,'6pgc[c]');
r5p = strcmpi(model.mets,'r5p[c]');
ru5p = strcmpi(model.mets,'ru5p-D[c]');
x5p = strcmpi(model.mets,'xu5p-D[c]');
s7p = strcmpi(model.mets,'s7p[c]');
e4p = strcmpi(model.mets,'e4p[c]');
f6p = strcmpi(model.mets,'f6p[c]');
fdp = strcmpi(model.mets,'fdp[c]');
dhap = strcmpi(model.mets,'dhap[c]');
g3p = strcmpi(model.mets,'g3p[c]');
dpg = strcmpi(model.mets,'13dpg[c]');
pg3 = strcmpi(model.mets,'3pg[c]');
pg2 = strcmpi(model.mets,'2pg[c]');
pep = strcmpi(model.mets,'pep[c]');
pyr = strcmpi(model.mets,'pyr[c]');
ac = strcmpi(model.mets,'ac[c]');
actp = strcmpi(model.mets,'actp[c]');
accoa = strcmpi(model.mets,'accoa[c]');
cit = strcmpi(model.mets,'cit[c]');
icit = strcmpi(model.mets,'icit[c]');
akg = strcmpi(model.mets,'akg[c]');
suca = strcmpi(model.mets,'succoa[c]');
fum = strcmpi(model.mets,'fum[c]');
mal = strcmpi(model.mets,'mal[c]');

%calculate some Vmax's from FBA Vss
pvec = VmaxFBA(model,pvec,mc);

%known fluxes
knflxid = logical(~isnan(pvec.Vmax));
knid = false(model.nt_rxn,1);
knid(knflxid) = 1;

%initial flux calculation
vf = Vuptake;
vf(knid) = CKinetics(model,pvec,mc,find(knid));

vf(logical(Vuptake)) = Vuptake(logical(Vuptake));
knid(logical(Vuptake)) = 1;
vf(bmr) = mu;
knid(bmr) = 1;

[~,ck] = CKinetics(model,pvec,mc,find(vpts));
pvec.Vmax(vpts) = vf(vglc)/ck;
knid(vpts) = 1;
vf(vpts) = CKinetics(model,pvec,mc,find(vpts));

%upper glycolysis I   
[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,g6p,vpgi);

%pentose phosphate
nr = vf(vg6pd)-mu*mc(pgl);
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vpgl),nr,vf,knid);

nr = vf(vpgl)-mu*mc(pgc);
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vgnd),nr,vf,knid);

nr = (vf(vgnd)+mu*(-2*mc(s7p)-mc(r5p)-S(r5p)-mc(ru5p)+mc(e4p)+S(e4p)-mc(x5p)))/3;
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vtala),nr,vf,knid);

nr = -vf(vtala)-mu*mc(s7p);
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vtkt1),nr,vf,knid);

nr = -vf(vtala)+mu*mc(e4p)+mu*S(e4p);
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vtkt2),nr,vf,knid);

nr = vf(vtkt1)-mu*mc(r5p)-mu*S(r5p);
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vrpi),nr,vf,knid);

nr = vf(vrpi)+vf(vgnd)-mu*mc(ru5p);
[pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vrpe),nr,vf,knid);

%upper glycolysis II
[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,f6p,vpfk);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,fdp,vfba);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,dhap,vtpi);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,g3p,vgapd);

%lower glycolysis I
[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,dpg,vpgk);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,pg3,vpgm);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,pg2,veno);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,pep,vppc);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,pyr,vpdh);

%acetate
[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,ac,vack);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,actp,vpta);

%lower glycolysis II
[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,accoa,vcs);

%tca cycle
[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,cit,vacont);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,icit,vicd);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,akg,vakgd);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,suca,vsuca);

% [vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,suc,vsuca);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,fum,vfum);

[vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,mal,vmdh);

% [vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,oaa,vsuca);

%other Vmax's
pvec.Vmax(model.VFex) = 1;

% for irxn = 1:length(unkw)
%     if ismember(unkw(irxn),model.Vex)
%         pvec.Vmax(unkw(irxn)) = 1;
%         knid(unkw(irxn)) = 1;
%     end
% end


function [vf,pvec,knid] = linearfluxes(model,vf,mc,mu,knid,pvec,metid,vid)
    vmet_f = model.S(metid,:);
    vknw = setdiff(find(vmet_f),find(vid));
    if model.S(metid,vid)<0
        nr = model.S(metid,vknw)*vf(vknw)-mu*mc(metid);
    else
        nr = -(model.S(metid,vknw)*vf(vknw)-mu*mc(metid));
    end
    [pvec,vf,knid] = Vmax_sub1(model,pvec,mc,find(vid),nr,vf,knid);
%     [~,ck] = CKinetics(model,pvec,mc,find(rxnid));
%     pvec.Vmax(rxnid) = (model.S(metid,vknw)*vf(vknw)-mu*mc(metid))/ck;
%     knidx(rxnid) = 1;
%     vf(rxnid) = CKinetics(model,pvec,mc,find(rxnid));
return

function [pvec,vf,knid] = Vmax_sub1(model,pvec,mc,vid,nr,vf,knid)

[~,ck] = CKinetics(model,pvec,mc,vid);
if ~knid(vid)
    if ck
        if nr/ck < 0
            pvec.Vmax(vid) = model.Vss(vid)/ck;
        else
            pvec.Vmax(vid) = nr/ck;
        end
    else
        pvec.Vmax(vid) = 0;
    end
end
vf(vid) = CKinetics(model,pvec,mc,vid);
knid(vid) = 1;