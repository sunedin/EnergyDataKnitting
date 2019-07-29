cd(dirname(@__FILE__))
using Suppressor: @suppress_err
include("$(pwd())/julia/functions.jl")
include("$(pwd())/julia/optimization_model.jl")
cd("$(pwd())/ampl")

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

for i in 1:ITmax - 1
    println(i)
    global rmp,L,U,Δ,x_fix,θ,λ
    solve(rmp) # solve relaxed master problem
    push!(L,getobjectivevalue(rmp)) # get lower bound
    x_fix = getvalue(rmp[:x_inv][:]) # get invextment decisions
    print_for_AMPL("Capacities.dat",G_AMPL,jl_to_ampl(x_fix)) # send decisions to ampl
    run(`ampl Operational.run`) # run operational subproblem in ampl
    θ = CSV.read("OpCost.csv")[:oper][1] # get operational cost
    push!(U,getvalue(rmp[:cx]) + θ) # compute upper bound
    λ = ampl_to_jl([CSV.read("Duals_Capacity.csv",use_mmap = false,nullable = false)[:Expr_1][i] for i in 1:5]) # get dual variables
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
