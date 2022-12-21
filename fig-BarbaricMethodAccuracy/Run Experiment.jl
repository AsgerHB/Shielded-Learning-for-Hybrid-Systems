if !isfile("Project.toml")
    error("Project.toml not found. Try running this script from the root of the ReproducibilityPackage folder.")
end

import Pkg
Pkg.activate(".")
Pkg.instantiate()
include("../Shared Code/ExperimentUtilities.jl")
using Dates

# cli args
args = my_parse_args(ARGS)
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
estimated_time = (1.24e-6)*NBPARAMS["squares_to_test"]*NBPARAMS["samples_per_square"]*19 + 60*2
progress_update("Estimated time: $(estimated_time) seconds")


include("Reliability of Barbaric Method.jl")

progress_update("Computation done.")
progress_update("Saving  to $results_dir")

# Figure saved in notebook as p1 etc...
savefig(p1, joinpath(results_dir, "BarbaricAccuracyN.png"))
savefig(p1, joinpath(results_dir, "BarbaricAccuracyN.svg"))
progress_update("Saved BarbaricAccuracyN")

savefig(p2, joinpath(results_dir, "BarbaricAccuracyGranularity.png"))
savefig(p2, joinpath(results_dir, "BarbaricAccuracyGranularity.svg"))
progress_update("Saved BarbaricAccuracyGranularity")

open(joinpath(results_dir, "rawdata.txt"), "a") do file
    println(file, "Accuracy as a function of N)")
    println(file, "(Using G=$(grid.G)")
    println(file, "N: $spa_values")
    println(file, "Accuracy: $spa_accuracies")
    println(file, "")
    println(file, "Accuracy as a function of G)")
    println(file, "(Using N=$(granularity_test_params.samples_per_axis)")
    println(file, "G: $granularities")
    println(file, "Accuracy: $granularity_accuracies")
 end


progress_update("Saved rawdata.txt")

progress_update("Done with $figure_name.")
progress_update("====================================")