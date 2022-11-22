//For cost of death in {1000, 100, 10}, train a strategy, save it, then evaluate it.
// HACK: Since this query file is only used for NoShield, I don't bother estimating the number of interventions. It will be zero, but I want to keep that number.

/* formula 1 */
strategy DeathCosts1000 = minE (LearnerPlayer.fired + number_deaths*1000 ) [<=120] {} -> {p, v}: <> time >= 120

/* formula 2 */
saveStrategy("%resultsdir%/DeathCosts1000.strategy.json", DeathCosts1000)

/* formula 3 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under DeathCosts1000

/* formula 4 */
E[<=120;%checks%] (max:number_deaths) under DeathCosts1000

/* formula 5 */
E[<=120;2] (max:interventions) under DeathCosts1000

/* formula 6 */
strategy DeathCosts100 = minE (LearnerPlayer.fired + number_deaths*100 ) [<=120] {} -> {p, v}: <> time >= 120

/* formula 7 */
saveStrategy("%resultsdir%/DeathCosts100.strategy.json", DeathCosts100)

/* formula 8 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under DeathCosts100

/* formula 9 */
E[<=120;%checks%] (max:number_deaths) under DeathCosts100

/* formula 10 */
E[<=120;2] (max:interventions) under DeathCosts100

/* formula 11 */
strategy DeathCosts10 = minE (LearnerPlayer.fired + number_deaths*10 ) [<=120] {} -> {p, v}: <> time >= 120

/* formula 12 */
saveStrategy("%resultsdir%/DeathCosts10.strategy.json", DeathCosts10)

/* formula 13 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under DeathCosts10

/* formula 14 */
E[<=120;%checks%] (max:number_deaths) under DeathCosts10

/* formula 15 */
E[<=120;2] (max:interventions) under DeathCosts10

