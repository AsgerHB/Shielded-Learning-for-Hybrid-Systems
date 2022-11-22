// Train a single strategy, save it, then evaluate it.

/* formula 1 */
strategy PreShielded = minE (LearnerPlayer.fired + number_deaths*1000 ) [<=120] {} -> {p[0], v[0], p[1], v[1], p[2], v[2]}: <> time >= 120

/* formula 2 */
saveStrategy("%resultsdir%/PreShielded.strategy.json", PreShielded)

/* formula 3 */
E[<=120;%checks%] (max:LearnerPlayer.fired) under PreShielded

/* formula 4 */
E[<=120;%checks%] (max:number_deaths) under PreShielded

/* formula 5 */
E[<=120;%checks%] (max:interventions) under PreShielded



