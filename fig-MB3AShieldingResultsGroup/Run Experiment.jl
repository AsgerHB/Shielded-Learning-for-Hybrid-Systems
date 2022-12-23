if !isfile("Project.toml")
    error("Project.toml not found. Try running this script from the root of the ReproducibilityPackage folder.")
end
import Pkg
Pkg.activate(".")
Pkg.instantiate()
using ArgParse
using Glob
using Dates
include("../Shared Code/ExperimentUtilities.jl")
include("Get libmb2shield.jl")

s = ArgParseSettings()

# infix operator "\join" redefined to signify joinpath
⨝ = joinpath

@add_arg_table s begin
    "--test"
        help="""Test-mode. Produce potentially useless results, but fast.
                Useful for testing if everything is set up."""
        action=:store_true

        "--results-dir"
            help="""Results will be saved in an appropriately named subdirectory.
                    Directory will be created if it does not exist."""
            default=homedir() ⨝ "Results"

        "--shield"
            help="""Shield file to use for the experiment. 
                    If no file is provided, a new shield will be synthesised and saved in the results dir."""
            default=nothing

        "--uppaal-dir"
            help="""Root directory of the UPPAAL STRATEGO 10 install."""
            default=homedir() ⨝ "opt/uppaal-4.1.20-stratego-10-linux64/"

        "--skip-experiment"
            help="""Yea I know. But figures will still be created from <results-dir>/Query Results/Results.csv
                    If nothing else I need this for testing."""
            action=:store_true
end

args = parse_args(s)

progress_update("Estimated total time to commplete: 19 hours. (30 minutes if run with --test)")

results_dir = args["results-dir"]
const figure_name = "fig-MB3AShieldingResultsGroup"
results_dir = results_dir ⨝ figure_name

queries_models_dir = results_dir ⨝ "UPPAAL Queries and Models"
mkpath(queries_models_dir)

query_results_dir = results_dir ⨝ "Query Results"
mkpath(query_results_dir)

libmb2shield_dir = results_dir ⨝ "libbshield"
mkpath(libmb2shield_dir)

possible_shield_file = args["shield"] #results_dir ⨝ "../tab-BBSynthesis/Exported Strategies/400 Samples 0.01 G.shield"

checks = args["test"] ? 10 : 1000 # Number of checks to use for estimating½ expected outcomes in the UPPAAL queries

const number_of_balls = 3

if !args["skip-experiment"]
    # Get the nondeterministic safe strategy that will be used for shielding.
    # Or just the "shield" for short.
    libmb2shield_file = libmb2shield_dir ⨝ "libmb2shield.so"
    get_libmb2shield(possible_shield_file, "Shared Code/libbbshield/", libmb2shield_file, working_dir=libmb2shield_dir, test=args["test"])


    # Create UPPAAL models and queries from blueprints, by doing search and replace on the placeholders.
    # This is similar to templating, but the word blueprint was choseen to avoid a name clash with UPPAAL templates. 
    blueprints_dir = pwd() ⨝ figure_name ⨝ "Blueprints" # TODO: $figure_name/Blueprints

    if !isdir(blueprints_dir)
        throw(error("Blueprints folder not found. Make sure this script is exectued from the root of the code folder.\nCurrent directory: $(pwd())\nContents: $(readdir())"))
    end

    replacements = Dict(
        "%resultsdir%" => query_results_dir,
        "%shieldfile%" => libmb2shield_file,
        "%checks%" => checks
    )

    search_and_replace(blueprints_dir, queries_models_dir, replacements)

    # I don't recall why I wrote this particular code in python.
    # I think it was because I knew how to use python's os.system() but not julia's run().
    # And as you can see, Julia's run() is kind of strange. https://docs.julialang.org/en/v1/manual/running-external-programs/

    cmd = [
        "python3", figure_name ⨝ "All Queries.py", 
        "--results-dir", query_results_dir,
        "--queries-models-dir", queries_models_dir,
        "--uppaal-dir", args["uppaal-dir"],
    ]

    if args["test"]
        push!(cmd, "--test")
    end

    cmd = Cmd(cmd)

    progress_update("Starting up Python script 'All Queries.py'")

    run(`echo $cmd`)

    Base.exit_on_sigint(false)

    try
        run(cmd)
    catch ex
        if isa(ex, InterruptException)
            # Couldn't figure out how to kill by handle lol
            # If you're using other python apps or something, that's tough.
            println("Interrupt Handling: Killing child processes using killall. \n(And whichever other process are unlucky enough to share their names 💀)")
            killcommand = `killall python3`
            run(`echo $killcommand`)
            run(killcommand, wait=false)
            killcommand = `killall verifyta`
            run(`echo $killcommand`)
            run(killcommand, wait=false)
        end
        throw(ex)
    end
    progress_update("Computation done.")
end

progress_update("Saving  to $results_dir")

NBPARAMS = Dict(
    "selected_file" => results_dir ⨝ "Query Results/Results.csv",
    "layabout" => true,
    "checks" => checks
)

include("ReadResults.jl")

average_cost_name = "MB3AShieldingResults"
savefig(average_cost, results_dir ⨝ "$average_cost_name.png")
savefig(average_cost, results_dir ⨝ "$average_cost_name.svg")
progress_update("Saved $average_cost_name")

average_interventions_name = "MB3AShieldingInterventions"
savefig(average_interventions, results_dir ⨝ "$average_interventions_name.png")
savefig(average_interventions, results_dir ⨝ "$average_interventions_name.svg")
progress_update("Saved $average_interventions_name")

average_deaths_name = "MB3AShieldingDeaths"
savefig(average_deaths, results_dir ⨝ "$average_deaths_name.png")
savefig(average_deaths, results_dir ⨝ "$average_deaths_name.svg")
progress_update("Saved $average_deaths_name")

write(results_dir ⨝ "SafetyNotice.md", safety_violations_message)
if safety_violations !== nothing
    progress_update("WARNING: Safety violation observed in shielded configuration. This is unexpected.")
else
    progress_update("No deaths observed in pre-shielded or post-shielded models.")
end

progress_update("Done with $figure_name.")
progress_update("====================================")