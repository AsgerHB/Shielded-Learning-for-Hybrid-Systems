import Pkg
using Dates
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

progress_update("Synthesizing safe strategies to build figure fig:NoRecovery.")
progress_update("Time to complete is approximately 50 minutes. (2 minutes with argument --test)")
    

include("BB No Recovery.jl")

fig_norecovery = "fig-NoRecovery"

# Figure saved in notebook as p1 etc...
savefig(p1, "$fig_norecovery.png")
savefig(p1, "$fig_norecovery.svg")
display(p1)

progress_update("Saved $fig_norecovery to $(abspath(fig_norecovery)).png")
