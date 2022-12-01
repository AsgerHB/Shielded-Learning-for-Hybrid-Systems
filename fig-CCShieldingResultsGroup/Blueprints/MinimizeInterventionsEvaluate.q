
/* formula 1 */
strategy MinInterventions = minE (interventions) [<=120] {} -> {rVelocityEgo, rVelocityFront, rDistance}: <> time >= 120

/* formula 2 */
saveStrategy("%resultsdir%/MinInterventions.strategy.json", MinInterventions)

/* formula 3 */
E[<=120;1000] (max: D/1000)                          under MinInterventions

/* formula 4 */
E[<=120;1000] (max:(distance <= 0))                 under MinInterventions

/* formula 5 */
E[<=120;2] (max: interventions)                     under MinInterventions


