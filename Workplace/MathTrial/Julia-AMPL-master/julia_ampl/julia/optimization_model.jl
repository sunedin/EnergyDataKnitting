using JuMP,Gurobi

function RMP(G::UnitRange{Int64},
         c_inv::Array{Float64,1},
         c_fix::Array{Float64,1},
         x_max::Array{Float64,1})

    m = Model(solver=GurobiSolver(OutputFlag=0))
    @variable(  m, 0 <= x_inv[g=G] <= x_max[g]) # accumulated capacity of thech. g (MW)
    @variable(  m, cx ) # investment cost (£)
    @variable(  m, θ >= 0.    ) # operational cost (£)
    @objective( m, :Min, cx + θ)
    @constraint(m, inv_cost, cx == sum((c_inv[g]+c_fix[g])*x_inv[g] for g in G))
    return m
end
