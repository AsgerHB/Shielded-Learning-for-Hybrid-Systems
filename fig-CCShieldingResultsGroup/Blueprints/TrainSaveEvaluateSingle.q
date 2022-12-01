// Train a single strategy, save it, then evaluate it.

/* formula 1 */
strategy PreShielded = minE (D/1000 + (distance <= 0)*1000.0) [<=120] {} -> {rVelocityEgo, rVelocityFront, rDistance}: <> time >= 120

/* formula 2 */
saveStrategy("%resultsdir%/PreShielded.strategy.json", PreShielded)

/* formula 3 */
E[<=120;1000] (max: D/1000)                           under PreShielded

/* formula 4 */
E[<=120;1000] (max:(distance <= 0))                  under PreShielded

/* formula 5 */
E[<=120;2] (max: 0)                      under PreShielded


