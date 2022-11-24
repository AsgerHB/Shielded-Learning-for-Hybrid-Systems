if !isfile("Project.toml")
    error("Project.toml not found. Try running this script from the root of the ReproducibilityPackage folder.")
end

using Pkg
Pkg.activate(".")
Pkg.instantiate()
using ArgParse

# infix operator "\join" redefined to signify joinpath
⨝ = joinpath

figure_name = "fig-BBShieldRobustness"

s = ArgParseSettings()

@add_arg_table s begin
    "--test"
    help = """Test-mode. Produce potentially useless results, but fast.
              Useful for testing if everything is set up."""
    action = :store_true

    "--results-dir"
    help = """Results will be saved in an appropriately named subdirectory.
              Directory will be created if it does not exist."""
    default = homedir() ⨝ "Results"

    "--shield"
    help = """Shield file to use for the experiment. 
              If no file is provided, a new shield will be synthesised and saved in the results dir."""
    default = nothing

    "--uppaal-dir"
    help = """Root directory of the UPPAAL STRATEGO 10 install."""
    default = homedir() ⨝ "opt/uppaal-4.1.20-stratego-10-linux64/"

    "--skip-experiment"
    help = """Yea I know. But figures will still be created from <results-dir>/Query Results/Results.csv
              If nothing else I need this for testing."""
    action = :store_true
end

args = parse_args(s)

# Remaining usings after ArgParse to speed up error reporting.
using ProgressLogging
using Glob
using Dates
using CSV
using Plots
include("../Shared Code/ExperimentUtilities.jl")
include("Get libbbshield.jl")


results_dir = args["results-dir"]
results_dir = results_dir ⨝ figure_name

possible_shield_file = args["shield"] #results_dir ⨝ "../tab-BBSynthesis/Exported Strategies/400 Samples 0.01 G.shield"

shield_file = get_shield(possible_shield_file, results_dir, test=args["test"])


progress_update("Testing the shield's robustness...")

NBPARAMS = Dict(
    "results_dir" => results_dir,
    "shield_file" => shield_file,
    "runs_per_configuration" => args["test"] ? 10 : 10000
)

include("Check Robustness of Shields.jl")

progress_update("Saving  to $results_dir")

robustness_plot_name = "BBShieldRobustness"
savefig(robustness_plot, results_dir ⨝ "$robustness_plot_name.png")
savefig(robustness_plot, results_dir ⨝ "$robustness_plot_name.svg")
progress_update("Saved $robustness_plot_name")


progress_update("Done with $figure_name.")
progress_update("====================================")