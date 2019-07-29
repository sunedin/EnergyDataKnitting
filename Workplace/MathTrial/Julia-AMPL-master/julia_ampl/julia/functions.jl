using CSV

G_JL   = Dict(1=>"coal",2=>"ocgt",3=>"ccgt",4=>"diesel",5=>"nuclear")
G_AMPL = Dict(1=>"Gcoal",2=>"Gocgt",3=>"Gccgt",4=>"Gnucl",5=>"Gdies")

function jl_to_ampl(a::Array{Float64,1})::Array{Float64,1}
    b = zeros(5)
    b[:] = [a[1],a[2],a[3],a[5],a[4]]
    return b
end

function ampl_to_jl(a::Array{Float64,1})::Array{Float64,1}
    b = zeros(5)
    b[:] = [a[1],a[2],a[3],a[5],a[4]]
    return b
end

G = 1:5
c_inv = [59500.,16000.,24200.,12800.,125000.] #(£/MW year)
c_fix = [26840., 5000.,10910., 3000., 66230.] #(£/MW year)
x_max = [35.,35.,35., 5.,  7.] .*1000         #(MW)

function print_for_AMPL(filenameOUT::String,Gdict::Dict{Int64,String},X::Array{Float64,1})
    open(filenameOUT, "w") do f
        write(f,"param:     pG_ub:=\n" )
        for g in G write(f,Gdict[g]*"      $(X[g])\n") end
        write(f,";")
    end
end
