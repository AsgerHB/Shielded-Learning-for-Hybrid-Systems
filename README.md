# ReproducibilityPackage

## Installation Instructions

This package was developed and tested on Ubuntu 22.04.1 LTS. These instructions apply to that operating system.

### Packages
Make sure you have the following packages installed on your system:

	sudo apt install gcc wget python3.10 default-jre

### Install julia 1.8.2

	cd ~/Downloads
	wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz
	tar zxvf julia-1.8.2-linux-x86_64.tar.gz
	mv julia-1.8.2/ ~/julia-1.8.2
	sudo ln -s ~/julia-1.8.2/bin/julia /usr/local/bin/julia

Download dependencies for this repository. Note that the `]` key activates the package manager interface.

	cd /path/to/this/repository
	julia
	] instantiate

### Install the GridShielding Package

The package has not yet beed added to the Julia packages repository, and so has to be downloaded manually from GitHub.

	mkdir -p ~/.julia/dev
	cd .julia/dev
	git clone https://github.com/AsgerHB/GridShielding.jl GridShielding
	

### Install UPPAAL STRATEGO 10 and Activate License
If the following wget request is denied, please visit uppaal.org and follow download instructions.

	mkdir ~/opt
	cd ~/opt
	wget https://download.uppaal.org/uppaal-4.1.20-stratego/stratego-11/uppaal-4.1.20-stratego-11-linux64.zip
	unzip uppaal-4.1.20-stratego-11-linux64.zip

Retrieve a license from https://uppaal.veriaal.dk/academic.html or alternatively visit uppaal.org for more info. Once you have your license, activate it by running 

	~/opt/uppaal-4.1.20-stratego-11-linux64/uppaal

Enter your license when prompted.

## How to run

Create figures by running their corresponding experiment. Shown here for fig-BarbaricMethodAccuracy

	cd path/to/ReproducibilityPackage
	julia "fig-BarbaricMethodAccuracy/Run Experiment.jl" --results-dir ~/Results

# Scratchpad and remarks

## Glossary of Code Abbreviations

I am a big fan of not having to remember how a variable has been abbreviated, but sometimes I have to make an exception. Additionally, I tried at one point to use the same notation as the paper. This I have come to regret, since the notation in the paper has been changing too rapidly to keep up with in the code.

 - `shield` The term "shield" is used interchangably with "nondeterministic safety strategy". Shields should have type `Grid`.
 - `grid` refers to a partitioning of the state space, plus an integer value associated with each partition. This integer is used in various ways to represent the set of allowable actions in that partition. Thus, a grid could have also been called a safety strategy. 
 - `G` is the granularity of the grid, currently δ in the paper.
 - `Ivl, Ivu, Ixl, Ixu ...` Are used to represeent upper and lower bounds for a partition. The `I` is short for _interval_, followed by the variable, and then either an `l` or an `u` depending on whether it is the lower or upper bound.
 - `iv, ix ...` are used to represent indices into the matrix that is the underlying data structure of the grid. For example if a grid has `v_min=-8`, and `G=1` then `iv=9` would represent the square where `Ivl = iv*G + (v_min/G) = 9 - 8 = 1`
 - `R` Reachability funciton. A function that given an initial square and an action, returns all squares reachable from the latter by that action. Similar to the reachability arrow, -> in the article.
 - `R̂` Approximated reachability function. Usually the barbaric reachability function. Similar to ->_app in the article. 
 - `grid_points` Support points in the paper. A cloud of evenly spaced points inside of a square, used to approximate reachability.
 - `spa` Samples Per Axis, in the context of grid-points. Called N in the paper.
 - `dir` This is an easy one. Short for directory. The (relative) path of a file or a folder.
 - `t` Time. 
 - `t_hit` Period between actions for the bouncing ball. `t_act` for cruise control.
 - `v, p` Velocity, Position. 
 - `death` Safety violation. Term borrowed from video games.
 - `runs` Training runs. These are called episodes in the paper.
