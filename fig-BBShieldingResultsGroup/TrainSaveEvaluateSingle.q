// Train a single strategy, save it, then evaluate it.

/* formula 1 */
strategy PreShielded = minE (LearnerPlayer.fired + number_deaths*1000 ) [<=120] {} -> {p, v}: <> time >= 120

/* formula 2 */
saveStrategy("/home/asger/Experiments/B3/PreShielded.strategy.json", PreShielded)

/* formula 3 */
E[<=120;1000] (max:LearnerPlayer.fired) under PreShielded

/* formula 4 */
E[<=120;1000] (max:number_deaths) under PreShielded

/* formula 5 */
E[<=120;1000] (max:interventions) under PreShielded