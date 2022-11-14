import Pkg
using Dates
Pkg.activate(".")
include("../Shared Code/ExperimentUtilities.jl")

# cli args
args = parse_args(ARGS)
if haskey(args, "help")
    print("""
    --help              Display this help and exit.
    --test              Test-mode. Produce potentially useless results, but fast. Useful for testing if everything is set up.
    --results-dir       Results will be saved in an appropriately named subdirectory. Directory will be created if it does not exist.
                        Default: '~/Results'
    """)
    exit()
end
test = haskey(args, "test")
results_dir = get(args, "results-dir", "$(homedir())/Results")
figure_name = "fig-BarbaricMethodAccuracy"
results_dir = joinpath(results_dir, figure_name)
mkpath(results_dir)

if test
    NBPARAMS = Dict(
        # The product of these two numbers will be the total number of tests. (10000)
        "squares_to_test" => 100,
        "samples_per_square" => 100,
    )
else
    NBPARAMS = Dict(
        # The product of these two numbers will be the total number of tests. (10000000)
        "squares_to_test" => 100000,
        "samples_per_square" => 1000,
    )
end

progress_update("Checking reachability function to build figure fig:NoRecovery...")
estimated_time = (1.24e-6)*NBPARAMS["squares_to_test"]*NBPARAMS["samples_per_square"]*19 + 60
progress_update("Estimated time: $(estimated_time) seconds")


include("Reliability of Barbaric Method.jl")

progress_update("Computation done.")
progress_update("Saving  to $results_dir")

# Figure saved in notebook as p1 etc...
savefig(p1, joinpath(results_dir, "$(figure_name)1.png"))
savefig(p1, joinpath(results_dir, "$(figure_name)1.svg"))
savefig(p2, joinpath(results_dir, "$(figure_name)2.png"))
savefig(p2, joinpath(results_dir, "$(figure_name)2.svg"))
progress_update("Saved $(figure_name)1")
progress_update("Saved $(figure_name)2")

open(joinpath(results_dir, "rawdata.txt"), "a") do file
    println(file, "spa_values: $spa_values")
    println(file, "accuracies: $accuracies")
 end


progress_update("Saved rawdata.txt")

progress_update("Done with $figure_name.")
progress_update("====================================")