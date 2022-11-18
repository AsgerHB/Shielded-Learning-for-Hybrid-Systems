import Pkg
using Dates
Pkg.activate(".")
Pkg.instantiate()
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
                        Useful if there are already shields saved in the results dir.
    --skip-evaluation   Do not evaluate the strategies' safety after synthesis is done.
    """)
    exit()
end
test = haskey(args, "test")
results_dir = get(args, "results-dir", "$(homedir())/Results")
table_name = "tab-CCSynthesis"
results_dir = joinpath(results_dir, table_name)
shields_dir = joinpath(results_dir, "Exported Strategies")
mkpath(shields_dir)
evaluations_dir = joinpath(results_dir, "Safety Evaluations")
mkpath(evaluations_dir)

make_barbaric_shields = !haskey(args, "skip-barbaric")
test_shields = !haskey(args, "skip-evaluation")


#########
# Setup #
#########

include("CC Synthesize Set of Shields.jl")
include("CC Statistical Checking of Shield.jl")

if !test
    # HARDCODED: Parameters to generate shield. All variations will be used.
    samples_per_axiss = [1, 2, 3, 5]
    Gs = [1, 0.5]

    # HARDCODED: Safety checking parameters.
    runs_per_shield = 1000000
else 
    # Test params that produce uninteresting results quickly
    samples_per_axiss = [2]
    Gs = [1]
    
    runs_per_shield = 100
end

##############
# Mainmatter #
##############

if make_barbaric_shields
    make_and_save_barbaric_shields(samples_per_axiss, Gs, shields_dir)
else
    progress_update("Skipping synthesis of shields using sampling-based reachability analysis.")
end

if test_shields
    test_shields_and_save_results(shields_dir, evaluations_dir, runs_per_shield)
else
    progress_update("Skipping tests of shields")
end


######################
# Constructing Table #
######################

NBPARAMS = Dict(
    # The product of these two numbers will be the total number of tests. (10000000)
    "csv_synthesis_report" => joinpath(shields_dir, "Barbaric Shields Synthesis Report.csv"),
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