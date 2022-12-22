if !isfile("Project.toml")
    error("Project.toml not found. Try running this script from the root of the ReproducibilityPackage folder.")
end
import Pkg
Pkg.activate(".")
Pkg.instantiate()


using ArgParse
s = ArgParseSettings()

# infix operator "\join" redefined to signify joinpath
⨝ = joinpath

@add_arg_table s begin
    "--test"
    help = """Test-mode. Produce potentially useless results, but fast.
              Useful for testing if everything is set up."""
    action = :store_true

    "--results-dir"
        help="""Results will be saved in an appropriately named subdirectory.
                Directory will be created if it does not exist."""            
        default=homedir() ⨝ "Results"

    "--skip-experiment"
    help="""Yea I know. But figures will still be created from <results-dir>/Results.csv
            If nothing else I need this for testing."""
    action=:store_true
end

args = parse_args(s)


const figure_name = "fig-BarbaricMethodAccuracy"

results_dir = args["results-dir"]

mkpath(results_dir)

# Additional includes here to make arg parsing go through faster
using CSV
using Dates
using DataFrames
include("Reliability of Barbaric Method.jl")
include("../Shared Code/ExperimentUtilities.jl")

progress_update("Estimated total time to complete: ?? hours. (1 minute if run with --test)")

results_dir = joinpath(results_dir, figure_name)
mkpath(results_dir)

if !args["test"]
    squares_to_test = 1000000
    samples_per_square = 1000
    granularities = [1, 0.5, 0.25, 0.1, 0.05, 0.04, 0.02, 0.01]
    spa_values = [5:16;] # Values of `samples_per_axis` to test for
else
    squares_to_test = 100
    samples_per_square = 100
    granularities = [1, 0.5, 0.25, 0.1, 0.05, 0.04, 0.02, 0.01]
    spa_values = [5:16;] # Values of `samples_per_axis` to test for
end

samples_per_axis = 16
grid = Grid(0.01, -15, 15, 0, 10)


if !args["skip-experiment"]
    progress_update("Checking reachability function.")

    _, granularity_accuracies = compute_accuracies_for_granularity(granularities, samples_per_axis, bbmechanics; samples_per_square, squares_to_test)

    _, spa_accuracies = compute_accuracies_for_spa(grid, spa_values, bbmechanics; samples_per_square, squares_to_test)

    spa_df = DataFrame(hcat(spa_values, spa_accuracies), ["N", "Accuracy"])
    granularity_df = DataFrame(hcat(granularities, granularity_accuracies), ["δ", "Accuracy"])

    # Save as csv, txt
    export_table(results_dir, "BarbaricAccuracyN", spa_df)
    export_table(results_dir, "BarbaricAccuracyGranularity", granularity_df)

    progress_update("Computation done.")
end

spa_df = CSV.read(results_dir ⨝ "BarbaricAccuracyN.csv", DataFrame)
granularity_df = CSV.read(results_dir ⨝ "BarbaricAccuracyGranularity.csv", DataFrame)

spa_values = spa_df[!, "N"]
spa_accuracies = spa_df[!, "Accuracy"]
granularities = granularity_df[!, "δ"]
granularity_accuracies = granularity_df[!, "Accuracy"]

progress_update("Saving  to $results_dir")

p1 = plot_accuracies_spa(spa_values, spa_accuracies; samples_per_square, squares_to_test, G=grid.G)
p2 = plot_accuracies_granularity(granularities, granularity_accuracies; samples_per_square, squares_to_test, samples_per_axis)

export_figure(results_dir, "BarbaricAccuracyN", p1)
export_figure(results_dir, "BarbaricAccuracyGranularity", p2)

progress_update("Done with $figure_name.")
progress_update("====================================")