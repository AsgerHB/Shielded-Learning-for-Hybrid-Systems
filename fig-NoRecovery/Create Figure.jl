import Pkg
Pkg.activate("..")


include("../Shared Code/ExperimentUtilities.jl")

fig_norecovery = "fig-NoRecovery"

args = parse_args(ARGS)

test = haskey(args, "test")

if test
    NBPARAMS = Dict(
        "G" => 0.5,
        "samples_per_axis" => 2
    )
else
    NBPARAMS = Dict(
        "G" => 0.01,
        "samples_per_axis" => 20
    )
end
    

include("BB No Recovery.jl")

# Figure saved in notebook as p1 etc...
savefig(p1, "$fig_norecovery.png")
savefig(p1, "$fig_norecovery.svg")
display(p1)

println("Saved $fig_norecovery to $(abspath(fig_norecovery)).png")
