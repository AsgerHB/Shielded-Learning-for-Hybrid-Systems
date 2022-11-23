if !isfile("Project.toml")
    error("Project.toml not found. Try running this script from the root of the ReproducibilityPackage folder.")
end
import Pkg
Pkg.activate(".")
Pkg.instantiate()
using Dates
include("../Shared Code/ExperimentUtilities.jl")

#########
# Args  #
#########

args = my_parse_args(ARGS)
if haskey(args, "help")
    print("""
    --help              Display this help and exit.
    --test              Test-mode. Produce potentially useless results, but fast.
                        Useful for testing if everything is set up.
    --results-dir       Results will be saved in an appropriately named subdirectory.
                        Directory will be created if it does not exist.
                        Default: '~/Results'
    --skip-barbaric     Skip synthesis using barbaric reachability funciton.
    --skip-rigorous     Skip synthesis using the JuliaReach ReachabilityAnalysis package.
    --skip-evaluation   Do not evaluate the strategies' safety after synthesis is done.
    """)
    exit()
end
test = haskey(args, "test")
results_dir = get(args, "results-dir", "$(homedir())/Results")
table_name = "tab-BBSynthesis"
results_dir = joinpath(results_dir, table_name)
shields_dir = joinpath(results_dir, "Exported Strategies")
mkpath(shields_dir)
evaluations_dir = joinpath(results_dir, "Safety Evaluations")
mkpath(evaluations_dir)

make_barbaric_shields = !haskey(args, "skip-barbaric")
make_rigorous_shields = !haskey(args, "skip-rigorous")
test_shields = !haskey(args, "skip-evaluation")

#########
# Setup #
#########

include("Synthesize Set of Shields.jl")
include("Statistical Checking of Shield.jl")

if !test
    # HARDCODED: Parameters to generate shield. All variations will be used.
    samples_per_axiss = [1, 2, 3, 4, 8, 16, 20]
    barbaric_gridargss = [(0.02, -15, 15, 0, 12), (0.01, -15, 15, 0, 12)]

    # HARDCODED: Parameters to generate shield. All variations will be used.
    # algorithms = [
	# 	AlgorithmInfo(BOX(δ=0.01), 4, 
	# 		"BOX 0.01"),
	# 	AlgorithmInfo(BOX(δ=0.002), 20, 
	# 		"BOX 0.002"),
	# 	AlgorithmInfo(GLGM06(δ=0.01, max_order=10, approx_model=Forward()), 9,
	# 		"GLGM06 0.01"), 
	# 	AlgorithmInfo(GLGM06(δ=0.002, max_order=10, approx_model=Forward()), 11,
	# 		"GLGM06 0.002"),
    # ]
    # rigorous_gridargss = [(0.02, -15, 15, 0, 14), (0.01, -15, 15, 0, 12)]
    # Here is a set of parameters that should be able to finish over night
    algorithms = [
        AlgorithmInfo(BOX(δ=0.002), 20, "BOX 0.002"),
        AlgorithmInfo(BOX(δ=0.001), 30, "BOX 0.001"),
    ]
    rigorous_gridargss = [(0.01, -15, 15, 0, 12)]

    # HARDCODED: Safety checking parameters.
    random_agents_hit_chances = [1/4, 1/5, 1/8, 1/10, 0]
    runs_per_shield = 1000000
else 
    # Test params that produce uninteresting results quickly
    samples_per_axiss = [5]
    barbaric_gridargss = [(0.1, -15, 15, 0, 12), (0.02, -15, 15, 0, 12)]

    algorithms = [
		AlgorithmInfo(BOX(δ=0.01), 4, 
			"BOX 0.01"),
        #AlgorithmInfo(GLGM06(δ=0.01, max_order=10, approx_model=Forward()), 9,
        #    "GLGM06 0.01"), 
    ]
    rigorous_gridargss = [(0.5, -15, 15, 0, 12)]

    random_agents_hit_chances = [1/4, 1/5, 1/8, 1/10, 0]
    runs_per_shield = 100
end

##############
# Mainmatter #
##############

if make_barbaric_shields
    progress_update("Estimated time: $(test ? 60 : 3863) seconds")
    make_and_save_barbaric_shields(samples_per_axiss, barbaric_gridargss, shields_dir)
else
    progress_update("Skipping synthesis of shields using sampling-based reachability analysis.")
end

if make_rigorous_shields
    make_and_save_rigorous_shields(algorithms, rigorous_gridargss, shields_dir)
else
    progress_update("Skipping synthesis using ReachabilityAnalysis.jl package.")
end

if test_shields
    test_shields_and_save_results(shields_dir, evaluations_dir, random_agents_hit_chances, runs_per_shield)
else
    progress_update("Skipping tests of shields")
end

progress_update("Computation done.")

# The make_and_save*shields methods produce two seperate tables
# because my code is as near unworkable spaghetti as it is possible without prompting a rewrite.
# So I gotta merge the two. Let's go. 
using CSV
using DataFrames

barbric_df, rigorous_df = nothing, nothing

barbaric_file = joinpath(shields_dir, "Barbaric Shields Synthesis Report.csv")

if isfile(barbaric_file)
    barbric_df = 
        open(barbaric_file) do file
            CSV.read(file, DataFrame)	
        end
end

rigorous_file = joinpath(shields_dir, "Rigorous Shields Synthesis Report.csv")

if isfile(rigorous_file)
    rigorous_df = 
        open(rigorous_file) do file
            CSV.read(file, DataFrame)
        end
end

joint_df = append!(something(barbric_df, DataFrame),
                 something(rigorous_df, DataFrame),
                 cols=:union)

joint_df |> CSV.write(joinpath(shields_dir, "Joint Shields Synthesis Report.csv"))



######################
# Constructing Table #
######################

NBPARAMS = Dict(
    # The product of these two numbers will be the total number of tests. (10000000)
    "csv_synthesis_report" => joinpath(shields_dir, "Joint Shields Synthesis Report.csv"),
    "csv_safety_report" => joinpath(evaluations_dir, "Test of Shields.csv")
)


###########
# Results #
###########



progress_update("Saving  to $results_dir")

include("Table from CSVs.jl")

CSV.write(joinpath(results_dir, "$table_name.csv"), joint_report)
write(joinpath(results_dir, "$table_name.txt"), "$joint_report")
write(joinpath(results_dir, "$table_name.tex"), "$resulting_latex_table")

# Oh god this is so hacky. These macros are used in the paper so I have to define them here also.
write(joinpath(results_dir, "macros.tex"), 
"""\\newcommand{\\granularity}{G}
\\newcommand{\\state}{s}""")


progress_update("Saved $(table_name)")

progress_update("Done with $table_name.")
progress_update("====================================")