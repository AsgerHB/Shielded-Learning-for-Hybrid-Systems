# How BB Reinforcement Learning is Affected by Shielding

Run from parent directory as 

	julia "fig-BBShieldingResultsGroup/Run Experiment"
	
!!! info "Tips:"
	Some cli args supported. View with `--help`.
	
	View progress using `tree` by doing `sudo apt install tree && tree %resultsdir%`. 

## Results Folder Structure

The figures will be in the root folder. The raw data they were created from will be in `Query Results/Results.csv`. This folder also contains the raw query results from running every configuration. 

Sample `Query Results` folder structure: 

	├── 0
	│   ├── Layabout
	│   │   └── Layabout.queryresults.txt
	│   ├── NoShield
	│   │   └── 1500Runs
	│   │       ├── DeathCosts1000.strategy.json
	│   │       ├── DeathCosts100.strategy.json
	│   │       ├── DeathCosts10.strategy.json
	│   │       └── NoShield.queryresults.txt
	│   ├── PostShielded
	│   │   └── 1500Runs
	│   │       └── PostShielded.queryresults.txt
	│   └── PreShielded
	│       └── 1500Runs
	│           ├── PreShielded.queryresults.txt
	│           └── PreShielded.strategy.json
	├── 1
	│   ├── Layabout
	│   │   └── Layabout.queryresults.txt
	[...]

The folders named with numbers 0-9 each contain a repeat of the whole experiment.

Each repeat contains the names of different configurations in their root. 

The layabout configuration is only run once (since it does not involve training) so it only contains a text file with the query results.

The other configurations will contain a folder for each different number of training runs used. These folders contain query results along with the exported strategies, if applicable.

The NoShield configurations have strategies trained with different penalties for safety violations.

The PreShielded configurations do not see safety violations and therefore only train one strategy each.

The PostShielded configurations borrow their strategies from NoShield.

## Code folder structure

Everything is tied together in `Run Experiment.jl`. This file retrieves an appropriate shield using the script `Get libbbshield.jl` and then feeds this into the UPPAAL models and queries. 

Queries are exectued against the models using the Python script `All Queries.py` which is what produces the folder `Query Results` described above.

UPPAAL models and queries are found in the `Blueprints` folder. They need to have specific values replaced, marked by `%template variables%` before they can be run. This is because UPPAAL does not handle relative file paths in a consistent way. 

The UPPAAL models are identical, save for the following variations:

 - **BB__Unhielded.xml** : `shield_enabled = false; layabout = false;`
 - **BB__Shielded.xml** : `shield_enabled = true; layabout = false;`
 - **BB__ShieldedLayabout.xml** : `shield_enabled = true; layabout = true;`
 
 Query files are used along with a model to create the configurations.
 
 - **TrainSaveEvaluate.q** : For cost of death in {1000, 100, 10}, train a strategy, save it, then evaluate it.
 - **TrainSaveEvaluateSingle.q** : Train a single strategy, save it, then evaluate it.
 - **NoStrategyEvaluate.q** : Evaluate the queries with no strategy applied.
 - **LoadEvaluate.q** : Load a strategy for cost of death in {1000, 100, 10}, then evaluate it.

The combinations are the following:

 - **Layabout**:	"BB__ShieldedLayabout.xml",  "NoStrategyEvaluate.q"
 - **NoShield**:	"BB__Unshielded.xml",  "TrainSaveEvaluate.q"
 - **PreShielded**:	"BB__Shielded.xml",  "LoadEvaluate.q"
 - **PostShielded**:	"BB__Shielded.xml",  "TrainSaveEvaluateSingle.q"
