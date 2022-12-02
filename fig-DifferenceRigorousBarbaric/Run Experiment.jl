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

shield1_default = homedir() ⨝ "Results/tab-BBSynthesis/Exported Strategies/400 Samples 0.01 G.shield"
shield2_default = homedir() ⨝ "Results/tab-BBSynthesis/Exported Strategies/BOX 0.001 with G of 0.01.shield"

@add_arg_table s begin
    "--results-dir"
        help="""Results will be saved in an appropriately named subdirectory.
                Directory will be created if it does not exist."""            
        default=homedir() ⨝ "Results"

    "--shield1"
        help="""First shield file to use for the experiment."""
        default=shield1_default

    "--shield2"
        help="""Second shield file to use for the experiment."""
        default=shield2_default

    "--color-mode"
        help="""Color theme to use for the differences. One of {transparent, distinctive}."""
        default="transparent"
end

args = parse_args(s)

results_dir = args["results-dir"]
const figure_name = "fig-DifferenceRigorousBarbaric"
results_dir = results_dir ⨝ figure_name

mkpath(results_dir)

using Plots
using Dates
using Serialization
include("../Shared Code/FlatUI.jl")
include("../Shared Code/ExperimentUtilities.jl")
include("../Shared Code/BBSquares.jl")

diffcolors = args["color-mode"] == "distinctive" ? [
	colors.SUNFLOWER,   # {hit, nohit} ~ {}
	colors.PETER_RIVER, # {hit} ~ {}
	colors.AMETHYST,    # {hit, nohit} ~ {hit}
	colors.WET_ASPHALT, # {hit, nohit} ~ {hit}
    colors.EMERALD,     # should not be used. included to prevent overflow
    colors.WET_ASPHALT, # should not be used. included to prevent overflow
    colors.ASBESTOS,    # should not be used. included to prevent overflow
    colors.ORANGE,      # should not be used. included to prevent overflow
] : args["color-mode"] == "transparent" ? [
	colorant"#ffc8bf", # {hit, nohit} ~ {}
	colorant"#dfbdbf", # {hit} ~ {}
	colorant"#cff2fe", # {hit, nohit} ~ {hit}
	colorant"#cff2fe", # should not be used. included to prevent overflow
	colorant"#dfbdbf", # should not be used. included to prevent overflow
	colorant"#ffc8bf", # should not be used. included to prevent overflow
] : error("--color-mode should be one of {distinctive, transparent}")

function error_on_missing(file::AbstractString)
    if !isfile(file)
        error("Could not find file $file")
    end
end

error_on_missing(args["shield1"])
error_on_missing(args["shield2"])

shield1 = robust_grid_deserialization(args["shield1"])
shield2 = robust_grid_deserialization(args["shield2"])

function get_descriptor(filename)
	if occursin("BOX", filename)
		return "BOX"
	elseif occursin(r"N|samples|Samples", filename)
		return "Barbaric"
	else
		return replace(filename, ".shield" => "")
	end
end

name1 = get_descriptor(args["shield1"])
name2 = get_descriptor(args["shield2"])


p1 = draw_diff(shield1, shield2, diffcolors, bbshieldcolors, bbshieldlabels; name1, name2,
    # plotargs
    xlabel="v", ylabel="p", legend_position=(0.72, 0.93),
    size=(1200, 900))


const name = "DifferenceRigorousBarbaric"

savefig(p1, results_dir ⨝ "$name.png")
savefig(p1, results_dir ⨝ "$name.svg")
progress_update("Saved $name")


