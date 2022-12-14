//For cost of death in {1000, 100, 10}, train a strategy, save it, then evaluate it.
// HACK: Since this query file is only used for NoShield, I don't bother estimating the number of interventions. It will be zero, but I want to keep that number.

/* formula 1 */
strategy DeathCosts1000 = minE (LearnerPlayer.fired + (number_deaths > 0)*1000 ) [<=120] {} -> {p[0], v[0], p[1], v[1], p[2], v[2]}: <> time >= 120

/* formula 2 */
saveStrategy("/home/asger/Experiments/G1/DeathCosts1000.strategy.json", DeathCosts1000)

/* formula 3 */
E[<=120;1000] (max:LearnerPlayer.fired) under DeathCosts1000

/* formula 4 */
E[<=120;1000] (max:(number_deaths > 0)) under DeathCosts1000

/* formula 5 */
E[<=120;2] (max:interventions) under DeathCosts1000

/* formula 6 */
strategy DeathCosts100 = minE (LearnerPlayer.fired + (number_deaths > 0)*100 ) [<=120] {} -> {p[0], v[0], p[1], v[1], p[2], v[2]}: <> time >= 120

/* formula 7 */
saveStrategy("/home/asger/Experiments/G1/DeathCosts100.strategy.json", DeathCosts100)

/* formula 8 */
E[<=120;1000] (max:LearnerPlayer.fired) under DeathCosts100

/* formula 9 */
E[<=120;1000] (max:(number_deaths > 0)) under DeathCosts100

/* formula 10 */
E[<=120;2] (max:interventions) under DeathCosts100

/* formula 11 */
strategy DeathCosts10 = minE (LearnerPlayer.fired + (number_deaths > 0)*10 ) [<=120] {} -> {p[0], v[0], p[1], v[1], p[2], v[2]}: <> time >= 120

/* formula 12 */
saveStrategy("/home/asger/Experiments/G1/DeathCosts10.strategy.json", DeathCosts10)

/* formula 13 */
E[<=120;1000] (max:LearnerPlayer.fired) under DeathCosts10

/* formula 14 */
E[<=120;1000] (max:(number_deaths > 0)) under DeathCosts10

/* formula 15 */
E[<=120;2] (max:interventions) under DeathCosts10


