import Pkg
Pkg.activate("..")
include("../Shared Code/ExperimentUtilities.jl")

# cli args
args = parse_args(ARGS)
if haskey(args, "help")
    print("""
    --help              Display this help and exit.
    --test              Test-mode. Produce potentially useless results, but fast. Useful for testing if everything is set up.
    """)
    exit()
end
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

fig_norecovery = "fig-NoRecovery"

# Figure saved in notebook as p1 etc...
savefig(p1, "$fig_norecovery.png")
savefig(p1, "$fig_norecovery.svg")
display(p1)

println("Saved $fig_norecovery to $(abspath(fig_norecovery)).png")
