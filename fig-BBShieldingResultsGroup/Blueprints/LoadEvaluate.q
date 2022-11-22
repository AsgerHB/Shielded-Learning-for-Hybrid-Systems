//Load a strategy for cost of death in {1000, 100, 10}, then evaluate it.

/* formula 1 */
strategy DeathCosts1000 = loadStrategy {} -> {p, v}("%resultsdir%/DeathCosts1000.strategy.json")

/* formula 2 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under DeathCosts1000

/* formula 3 */
E[<=120;%checks%] (max:number_deaths) under DeathCosts1000

/* formula 4 */
E[<=120;%checks%] (max:interventions) under DeathCosts1000

/* formula 5 */
strategy DeathCosts100 = loadStrategy {} -> {p, v}("%resultsdir%/DeathCosts100.strategy.json")

/* formula 6 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under DeathCosts100

/* formula 7 */
E[<=120;%checks%] (max:number_deaths) under DeathCosts100

/* formula 8 */
E[<=120;%checks%] (max:interventions) under DeathCosts100

/* formula 9 */
strategy DeathCosts10 = loadStrategy {} -> {p, v}("%resultsdir%/DeathCosts10.strategy.json")

/* formula 10 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under DeathCosts10

/* formula 11 */
E[<=120;%checks%] (max:number_deaths) under DeathCosts10

/* formula 12 */
E[<=120;%checks%] (max:interventions) under DeathCosts10
