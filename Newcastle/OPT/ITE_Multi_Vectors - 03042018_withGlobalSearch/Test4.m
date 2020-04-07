%% ------------ Initialization ------------ 
clear;
% Load Matpower
addpath('c:\Users\wsun\PycharmProjects\TheOtherSides\frictionlessdata\EnergyDataKnitting\Newcastle\matpower6.0\')
addpath('c:\Users\wsun\PycharmProjects\TheOtherSides\frictionlessdata\EnergyDataKnitting\Newcastle\matpower6.0/t')

% Get access to all the constant and variables, this is required by Matpower
define_constants

% Define the path for output file and functions
p = mfilename('fullpath');
fdir = fileparts(p);
addpath(fdir);
% Define the path for all functions
functionpath = strcat(fdir, '\ITE FCN');
addpath(functionpath);
% Define the path for all new functions for the gas vector
functionpath = strcat(fdir, '\ITE NEW FCN');
addpath(functionpath)

%% Load Electrical network
% Choose which electrical network model to run
% Network is defined by changing the name below
%     choose from '33kV', 'IEEE57bus', 'IEEE6bus'
Electrical_Model_Name = 'IEEE6bus';
if strcmp(Electrical_Model_Name, '33kV')
    modelpath = strcat(fdir,'\Electrical_Network_models\33kV');
    cd(modelpath);
    mpc = loadcase('meshed_withsop_LV.m');  
elseif strcmp(Electrical_Model_Name, 'IEEE57bus')
    modelpath = strcat(fdir,'\Electrical_Network_models\IEEE57bus');
    cd(modelpath);
    mpc = loadcase('case57_edt.m');
elseif strcmp(Electrical_Model_Name, '11kV')
    modelpath = strcat(fdir,'\Electrical_Network_models\11kV');
    cd(modelpath);
    mpc = loadcase('radial.m');   
elseif strcmp(Electrical_Model_Name, 'IEEE6bus')
    modelpath = strcat(fdir,'\Electrical_Network_models\IEEE6bus');
    cd(modelpath);
    mpc = loadcase('case6.m');
    VM=mpc.bus(:,8)';
    VA=mpc.bus(:,9)';
end
%% Load Gas network
% Choose which gas network model to run
% Network is defined by changing the name below
%     choose from '17_Node', 'Findhorn'
Gas_Model_Name = '17_Node';
if strcmp(Gas_Model_Name, '17_Node')
    modelpath = strcat(fdir,'\Gas Network models\17_Node_Network');
    cd(modelpath);
    mgc = case17Node; 
    % Initial Values of Pressure, Compressors powers, gas comsumption and flows
    Pressure = mgc.NodeData(:,5)';
    BHP = mgc.CompressorData(:,11)';
    tauc = mgc.CompressorData(:,12)';
    Fc = mgc.CompressorData(:,13)';
    Pgen = mgc.Pgen;
end
%% Loadflow setting
%itmax = maximum number of iterations permitted before the iterative
%process is terminated – protection against infinite iterative loops
%tol = criterion tolerance to be met before the iterative solution is
%successfully brought to an end
itmax = 5000;  
tol = 1e-6;     
% Run Gas and Power flows to define the initial state variables
[Pressure,BHP,Fc,tauc,Fp,Pgen,VA,VM,it,DH,PSlack,Pg,Qg] = GasPowerFlow(mpc,mgc,...
    tol,itmax,Pressure,Fc,tauc,BHP,VM,VA,Pgen);
%% define named indices into data matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM_idx, ...
    VA_idx, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;
%% process input arguments of the electric network
[mpc, mpopt] = opf_args(mpc);
%%-----  construct OPF model object of the Electric network -----
om = opf_setup(mpc, mpopt);
[baseMVA, bus, gen, branch]=deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
[vv, ll, nn] = get_idx(om);
%% problem dimensions of the electric network
nb = size(bus, 1);          %% number of buses
nl = size(branch, 1);       %% number of branches
ng = size(mpc.gen,1);       %% number of generaors
ny = getN(om, 'var', 'y');  %% number of piece-wise linear costs
%% bounds on optimization of electric vars
[x0e, LBe, UBe] = getv(om);
%% linear electric constraints 
[A, l, u] = linear_constraints(om);
% split l <= A*x <= u into less than, equal to, greater than, and
% doubly-bounded sets
ieq = find( abs(u-l) <= eps );          %% equality
igt = find( u >=  1e10 & l > -1e10 );   %% greater than, unbounded above
ilt = find( l <= -1e10 & u <  1e10 );   %% less than, unbounded below
ibx = find( (abs(u-l) > eps) & (u < 1e10) & (l > -1e10) );
Af  = [ A(ilt, :); -A(igt, :); A(ibx, :); -A(ibx, :) ];
[nln_Af,nCl_Af] = size(full(Af));
bf  = [ u(ilt);   -l(igt);     u(ibx);    -l(ibx)];
Afeq = A(ieq, :);
Afeq = full(Afeq);
[nln_Afeq, ncl_Afeq] = size(full(Afeq));
bfeq = u(ieq);
[nln_bfeq, ncl_bfeq] = size(bfeq);
%% build admittance matrices
[Ybus, Yf, Yt] = makeYbus(baseMVA, bus, branch);
%% find branches with flow limits
il = find(branch(:, RATE_A) ~= 0 & branch(:, RATE_A) < 1e10);
nl2 = length(il);           %% number of constrained lines
%% problem dimensions of the gas network
NN = mgc.NN;          %% number of nodes
nSource = mgc.nSource;       %% number of branches
%% bounds on optimization of gas vars
[vl_gas, vu_gas] = getv_gas(mgc);
%% find gas branches with flow limits
ilg = find(mgc.BranchData(:,10) ~= 0 & mgc.BranchData(:,10) < 1e10);
nlg2 = length(ilg);           %% number of constrained branches
%% define Initial state of Coupled networks
xe0 = [VA'*(pi/180);VM';Pg;Qg];
Ws = GasSourcesFlow(mgc,Fp);
PresSure_squared = Pressure.^2; 
xg0 = [PresSure_squared';Ws];
x0=[xe0;xg0];
%% Construct the Af_ge and bf_ge matrix (Af_ge*x <= Bf_ge)
len_bf = length(bf);
len_xg = length(xg0);
Af12 = sparse(len_bf,len_xg);
Af21 = sparse(0,nCl_Af);
A22 = sparse(0,len_xg);
bfg = sparse(0,1);
Afge = [full(Af) Af12;Af21 A22];
bfge = [bf;bfg];
%% Construct Aeq and beq
ig_source = find(mgc.SourceData(:,6) ==1); 
lig_source = length(ig_source);
Aeq_g = zeros(lig_source,len_xg);
Aeq_g(lig_source,lig_source)=1;
Aeq_ge = [full(Afeq) zeros(nln_Afeq,len_xg);
     zeros(lig_source,ncl_Afeq) Aeq_g];
bfeq_g = mgc.SourceData(ig_source,2)^2; 
beq_ge = [bfeq bfeq_g];
%% ----------------- Construct the bounded constraints --------------------  
LB_ge = [LBe;vl_gas];
i_slackBus = find( mpc.bus(:,2) ==3 );
LB_ge(i_slackBus) = -1;
UB_ge = [UBe;vu_gas];
UB_ge(i_slackBus) = 1;
%% basic optimset options needed for fmincon
fmoptions = optimset('GradObj', 'off', 'GradConstr', 'off','DerivativeCheck', 'on', ...
    'TolCon', 1e-6, 'TolX', 1e-20,'MaxIter',20000, ...
    'TolFun', 1e-6,'MaxFunEvals',800000);

if mpopt.verbose == 0
  fmoptions.Display = 'off';
elseif mpopt.verbose == 1
  fmoptions.Display = 'iter';
else
  fmoptions.Display = 'testing';
end
% select algorithm
fmoptions = optimset(fmoptions, 'Algorithm', 'interior-point');% 'sqp' 'interior-point'

%% ----------  run optimal gas and electric power flow  -------------------
rng default % For reproducibility
gs = GlobalSearch('Display','iter');
gh_fcn = @(x)NonLinearConstaints_V31(x,om,Ybus,Yf,Yt,mgc,mpopt,il,ilg);
f_fcn = @(x)CostFunction(om,mgc,x); %@(x)0
% problem = createOptimProblem('fmincon','objective', f_fcn, 'x0', x0, ...
%         'Aineq', Afge, 'bineq', bfge, 'Aeq', Aeq_ge, 'beq', beq_ge, 'lb', LB_ge, ...
%         'ub', UB_ge, 'nonlcon', gh_fcn, 'options', fmoptions);
% [x, f, info, Output, Lambda] = run(gs,problem);

[x, f, info, Output, Lambda] = ...
   fmincon(f_fcn, x0, Afge, bfge, Aeq_ge, beq_ge, LB_ge, UB_ge, gh_fcn, fmoptions);
% update solution data
Va = x(1:nb);
Va_degree= x(1:nb);
Vm = x(nb+1:2*nb);
Pg = x(2*nb+1:2*nb+ng);
Qg = x(2*nb+ng+1:2*nb+2*ng);
V = Vm .* exp(1j*Va);
Pressure = x(2*nb+2*ng+1:2*nb+2*ng+NN).^0.5;
Ws = x(2*nb+2*ng+NN+1:2*nb+2*ng+NN+nSource);
%%-----  calculate return values  -----
%% compute electric branch flows
Sf = V(branch(:, F_BUS)) .* conj(Yf * V);  %% cplx pwr at "from" bus, p.u.
St = V(branch(:, T_BUS)) .* conj(Yt * V);  %% cplx pwr at "to" bus, p.u.
branch(:, PF) = real(Sf) * baseMVA;
branch(:, QF) = imag(Sf) * baseMVA;
branch(:, PT) = real(St) * baseMVA;
branch(:, QT) = imag(St) * baseMVA;
%% compute gas branch flows
Fp = CalculatedPipelineFlow(mgc,Pressure);

