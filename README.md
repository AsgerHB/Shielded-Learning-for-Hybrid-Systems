# ReproducibilityPackage

## Installation Instructions

This package was developed and tested on Ubuntu 22.04.1 LTS. These instructions apply to that operating system.

### Install wget
(or download the things manually idc)

	sudo apt install wget

### Install gcc

	sudo apt install gcc

### Install julia 1.8.2

	cd ~/Downloads
	wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz
	tar zxvf julia-1.8.2-linux-x86_64.tar.gz
	mv julia-1.8.2/ ~/bin/julia-1.8.2
	echo export PATH="$PATH:/home/sammy/julia-1.8.1/bin"
	echo 'export PATH="$PATH:$HOME/julia-1.8.2/bin"' >> .bashrc 
	source .bashrc

### Install python 3.10

	sudo apt install python3.10
	
### Install UPPAAL STRATEGO 10
If the following wget request is denied, please visit uppaal.org and follow download instructions.

	mkdir ~/opt
	cd ~/opt
	wget https://uppaal.org/dl/uppaal-4.1.20-stratego-10-linux64.zip
	unzip uppaal-4.1.20-stratego-10-linux64.zip

## How to run

Create figures by running their corresponding experiment. Shown here for fig-BarbaricMethodAccuracy

	cd path/to/ReproducibilityPackage
	julia "fig-BarbaricMethodAccuracy/Run Experiment.jl --results-dir ~/Results"

# Scratchpad and remarks

The folder `Shared Code` is not committed at the time of writing. This is because I use a symlink to my other repo's folder My Library. This is to enable at least some code sharing. When I ship, this should no longer be the case.

Packages: 

	CSV DataFrames Dates Glob InteractiveUtils JSON Markdown ModelingToolkit NaturalSort Plots PlutoLinks PlutoSerialization PlutoUI Polyhedra PProf Printf Profile ProgressLogging Random ReachabilityAnalysis Serialization Statistics StatsBase StatsPlots Symbolics TimerOutputs Unzip XMLDict
