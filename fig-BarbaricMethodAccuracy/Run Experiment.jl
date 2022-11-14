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
        # The product of these two numbers will be the total number of tests. (10000)
        "squares_to_test" => 100,
        "samples_per_square" => 100,
    )
else
    NBPARAMS = Dict(
        # The product of these two numbers will be the total number of tests. (10000000)
        "squares_to_test" => 1000,
        "samples_per_square" => 10000,
    )
end

progress_update("Checking reachability function to build figure fig:NoRecovery...")
progress_update("Time to complete is approximately ?? minutes. (less than 1 with argument --test)")


include("Reliability of Barbaric Method.jl")

fig_barbaricmethodaccuracy = "fig-BarbaricMethodAccuracy"

# Figure saved in notebook as p1 etc...
savefig(p1, "$(fig_barbaricmethodaccuracy)1.png")
savefig(p1, "$(fig_barbaricmethodaccuracy)1.svg")
savefig(p2, "$(fig_barbaricmethodaccuracy)2.png")
savefig(p2, "$(fig_barbaricmethodaccuracy)2.svg")

progress_update("Saved $(fig_barbaricmethodaccuracy)1 to $(abspath(fig_barbaricmethodaccuracy))1.png")
progress_update("Saved $(fig_barbaricmethodaccuracy)2 to $(abspath(fig_barbaricmethodaccuracy))2.png")
