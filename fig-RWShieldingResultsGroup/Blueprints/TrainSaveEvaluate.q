//For cost of death in {1000, 100, 10}, train a strategy, save it, then evaluate it.
// HACK: Since this query file is only used for NoShield, I don't bother estimating the number of interventions. It will be zero, but I want to keep that number.

/* formula 1 */
strategy DeathCosts1000 = minE (total_cost + (t>1)*1000) [#<=30] {} -> {x, t} : <> x>=1 or t>=1

/* formula 2 */
saveStrategy("%resultsdir%/DeathCosts1000.strategy.json", DeathCosts1000)

/* formula 3 */
E[#<=30;%checks%] (max:total_cost) under DeathCosts1000

/* formula 4 */
E[#<=30;%checks%00] (max:t>1) under DeathCosts1000

/* formula 5 */
E[#<=30;%checks%] (max:interventions) under DeathCosts1000

/* formula 6 */
strategy DeathCosts100 = minE (total_cost + (t>1)*100) [#<=30] {} -> {x, t} : <> x>=1 or t>=1

/* formula 7 */
saveStrategy("%resultsdir%/DeathCosts100.strategy.json", DeathCosts100)

/* formula 8 */
E[#<=30;%checks%] (max:total_cost) under DeathCosts100

/* formula 9 */
E[#<=30;%checks%00] (max:t>1) under DeathCosts100

/* formula 10 */
E[#<=30;%checks%] (max:interventions) under DeathCosts100

/* formula 11 */
strategy DeathCosts10 = minE (total_cost + (t>1)*10) [#<=30] {} -> {x, t} : <> x>=1 or t>=1

/* formula 12 */
saveStrategy("%resultsdir%/DeathCosts10.strategy.json", DeathCosts10)

/* formula 13 */
E[#<=30;%checks%] (max:total_cost) under DeathCosts10

/* formula 14 */
E[#<=30;%checks%00] (max:t>1) under DeathCosts10

/* formula 15 */
E[#<=30;%checks%] (max:interventions) under DeathCosts10

