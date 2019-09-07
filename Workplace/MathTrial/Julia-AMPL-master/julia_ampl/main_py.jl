#=
main_py:
- Julia version: 0.6.4
- Author: wsun
- Date: 2019-07-05
=#
using Pkg
Pkg.add("PyCall")

cd(dirname(@__FILE__))
using Suppressor: @suppress_err
include("$(pwd())/julia/functions.jl")
include("$(pwd())/julia/optimization_model.jl")
cd("$(pwd())/ampl")

using PyCall
amplapi = pyimport("amplpy")
amplapi.AMPL().close()
ampl = amplapi.AMPL()

# call python interfacing package
py"""
import sys
sys.path.insert(0, "./EnergyDataKnitting/Workplace/MathTrial/Julia-AMPL-master/julia_ampl")
"""
Interface = pyimport("MappingPassOver")

# input info about model-specific item names and common names
G_JL = ["coal", "ocgt", "ccgt", "diesel", "nuclear"]
G_AMPL = ["Gcoal", "Gocgt", "Gccgt", "Gnucl", "Gdies"]
Common = ["Coal", "Ocgt", "Ccgt", "Diesel", "Nuclear"]
ModelA = G_JL
ModelB = G_AMPL

# set parameters
const ITmax = 20 # max number of iterations
const ϵ = .001 # tolerance gap (%)

G = 1:5
c_inv = [59500., 16000., 24200., 12800., 125000.] #(£/MW year)
c_fix = [26840., 5000., 10910., 3000., 66230.] #(£/MW year)
x_max = [35., 35., 35., 5., 7.] .*1000         #(MW)

rmp = RMP(G,c_inv,c_fix,x_max) # create relaxed master problem

L,U,Δ     = zeros(0),zeros(0),zeros(0)
x_fix,θ,λ = zeros(5),0.,zeros(5)

ampl.read("Operational-ini.run")

for i in 1:ITmax - 1
    println(i)
    global rmp,L,U,Δ,x_fix,θ,λ
    solve(rmp) # solve relaxed master problem
    push!(L,getobjectivevalue(rmp)) # get lower bound
    x_fix = getvalue(rmp[:x_inv][:]) # get invextment decisions

    #### model interfacing option 1: replacing the csv-file-based data exchange using ampl python API #####
#     ampl.getParameter("pG_ub").setValues(jl_to_ampl(x_fix))
    #### option 2: replacing the csv-file-based data exchange using automatic CrossMapping by checking model-specific item names with common names#####
    ampl.getParameter("pG_ub").setValues(Interface.CrossMapping(x_fix, ModelA, ModelB, Common))

    ampl.solve()
    θ = ampl.getValue("oper")
    push!(U,getvalue(rmp[:cx]) + θ) # compute upper bound
     print(typeof([c[2].dual() for c in ampl.getConstraint("lambda_pG")]))
#     λ = ampl_to_jl([c[2].dual() for c in ampl.getConstraint("lambda_pG")]) # option 1
    λ = Interface.CrossMapping([c[2].dual() for c in ampl.getConstraint("lambda_pG")], ModelB, ModelA, Common) # option 2
    print(typeof(λ))

    @constraint(rmp,rmp[:θ] >= θ + sum(λ[i] * (rmp[:x_inv][i] - x_fix[i]) for i in 1:5)) # update relaxed master problem
    push!(Δ,(U[end] - L[end]) / U[end] * 100)
    println(Δ[end])
        if (Δ[end] <= ϵ) break end
end

println(" ")
println("---------------------------------------------------------------------")
println("Investment Decisions")
println("coal    -> $(round(x_fix[1] / 1000; digits = 1)) GW")
println("ocgt    -> $(round(x_fix[2] / 1000; digits = 1)) GW")
println("ccgt    -> $(round(x_fix[3] / 1000; digits = 1)) GW")
println("diesel  -> $(round(x_fix[4] / 1000; digits = 1)) GW")
println("nuclear -> $(round(x_fix[5] / 1000; digits = 1)) GW")
println(" ")
println("Cost for investment -> $(round(getvalue(rmp[:cx]) / 10^9; digits = 3)) x 10^9 £")
println("Cost for operation  -> $(round(θ / 10^9; digits = 3)) x 10^9 £")
println("---------------------------------------------------------------------")
