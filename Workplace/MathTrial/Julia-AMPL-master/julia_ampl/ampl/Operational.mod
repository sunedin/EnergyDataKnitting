set sG;  # SET OF THERMAL GENERATORS
set sF ordered;  # SET OF FUELS
set sT := 1..730;

param pG_ub{sG};     # capacity (MW) received from "Capacities.dat";
##### SUBPROBLEM (ALWAYS FEASIBLE)
##################################
# --- parameters --- received from "Operational.dat";
param Dem{sT};
param W {sF};           # tonnes of CO2 produced on burning fuel f with energy content 1 MWhr
param Cfuel {sF};       # Cost of fuel per MWh of energy content.
param EG {sG};          # Efficiency of generator g, (ratio of output energy to input energy)
param VrOM {sG};        # Variable OM cost of generator g
param f {sG} symbolic;  # Fuel used by generator g
param DiscCost;         # Disconnection costs per MWh
param Alpha;            #
param CG {g in sG} := VrOM[g] + 1.0/EG[g]*Cfuel[f[g]]; # Cost per per MWh of generation from generator g

# --- variables ---
var pG_max{sG} >=0; # maximum power output (MW)
var pG{sG,sT}  >=0; # power output of generator g in period t (MWh)
var shed{sT}   >=0; # shedded demand at time t (MW)

# --- constraints ---
subject to balance   {t in sT}: sum{g in sG}(pG[g,t]) + shed[t] >= Dem[t];
subject to pG_ub_lim {g in sG, t in sT}: pG[g,t] <= pG_max[g];
subject to lambda_pG {g in sG}: pG_max[g] = pG_ub[g];

# --- objective function ---
minimize oper: sum{g in sG, t in sT}(Alpha*CG[g]*pG[g,t])+sum{t in sT}(Alpha*DiscCost*shed[t]) ;
