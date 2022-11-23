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
	mv julia-1.8.2/ ~/bin/julia-1.8.2
	echo export PATH="$PATH:/home/sammy/julia-1.8.1/bin"
	echo 'export PATH="$PATH:$HOME/julia-1.8.2/bin"' >> .bashrc 
	source .bashrc

	
	
### Install UPPAAL STRATEGO 10 and Activate License
If the following wget request is denied, please visit uppaal.org and follow download instructions.

	mkdir ~/opt
	cd ~/opt
	wget https://uppaal.org/dl/uppaal-4.1.20-stratego-10-linux64.zip
	unzip uppaal-4.1.20-stratego-10-linux64.zip

Retrieve a license from uppaal.veriaal.dk/academic.html or alternatively visit uppaal.org for more info. Once you have your license, activate it by running 

	~/opt/uppaal-4.1.20-stratego-10-linux64/uppaal

Enter your license when prompted.

## How to run

Create figures by running their corresponding experiment. Shown here for fig-BarbaricMethodAccuracy

	cd path/to/ReproducibilityPackage
	julia "fig-BarbaricMethodAccuracy/Run Experiment.jl --results-dir ~/Results"

# Scratchpad and remarks

The folder `Shared Code` is not committed at the time of writing. This is because I use a symlink to my other repo's folder My Library. This is to enable at least some code sharing. When I ship, this should no longer be the case.

Packages: 

	CSV DataFrames Dates Glob InteractiveUtils JSON Markdown ModelingToolkit NaturalSort Plots PlutoLinks PlutoSerialization PlutoUI Polyhedra PProf Printf Profile ProgressLogging Random ReachabilityAnalysis Serialization Statistics StatsBase StatsPlots Symbolics TimerOutputs Unzip XMLDict
