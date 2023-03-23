// Train a single strategy, save it, then evaluate it.

/* formula 1 */
strategy PreShielded = minE (aov/120 + switches/2) [<=120] {} -> {t, v, p, l}: <> elapsed >= 120

/* formula 2 */
saveStrategy("%resultsdir%/PreShielded.strategy.json", PreShielded)

/* formula 3 */
E[<=120;%checks%] (max:aov/120 + switches/2) under PreShielded

/* formula 4 */
E[<=120;%checks%] (max:(number_deaths > 0)) under PreShielded

/* formula 5 */
E[<=120;%checks%] (max:interventions) under PreShielded