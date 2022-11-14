# ReporducibilityPackage

This package was developed and tested on Ubuntu 22.04.1 LTS. These instructions will apply to that operating system.

Install julia 1.8.2:

	cd ~/Downloads
	wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz
	tar zxvf julia-1.8.2-linux-x86_64.tar.gz
	mv julia-1.8.2/ ~/bin/julia-1.8.2
	echo export PATH="$PATH:/home/sammy/julia-1.8.1/bin"
	echo 'export PATH="$PATH:$HOME/julia-1.8.2/bin"' >> .bashrc 
	source .bashrc

# Scratchpad and remarks

The folder `Shared Code` is not committed at the time of writing. This is because I use a symlink to my other repo's folder My Library. This is to enable at least some code sharing. When I ship, this should no longer be the case.

Packages: 

	CSV DataFrames Dates Glob InteractiveUtils JSON Markdown ModelingToolkit NaturalSort Plots PlutoLinks PlutoSerialization PlutoUI Polyhedra PProf Printf Profile ProgressLogging Random ReachabilityAnalysis Serialization Statistics StatsBase StatsPlots Symbolics TimerOutputs Unzip XMLDict
