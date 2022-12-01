//For cost of death in {1000, 100, 10}, train a strategy, save it, then evaluate it.
// HACK: Since this query file is only used for NoShield, I don't bother estimating the number of interventions. It will be zero, because I need a number to be printed.

/* formula 1 */
strategy DriveWell1000 = minE (D/1000 + (distance <= 0)*1000.0) [<=120] {} -> {rVelocityEgo, rVelocityFront, rDistance}: <> time >= 120

/* formula 2 */
saveStrategy("%resultsdir%/DriveWell1000.strategy.json", DriveWell1000)

/* formula 3 */
E[<=120;1000] (max: D/1000)                          under DriveWell1000

/* formula 4 */
E[<=120;1000] (max:(distance <= 0))                 under DriveWell1000

/* formula 5 */
E[<=120;2] (max: 0)                                 under DriveWell1000

/* formula 6 */
strategy DriveWell100 = minE (D/1000 + (distance <= 0)*100.0) [<=120] {} -> {rVelocityEgo, rVelocityFront, rDistance}: <> time >= 120

/* formula 7 */
saveStrategy("%resultsdir%/DriveWell100.strategy.json", DriveWell100)

/* formula 8 */
E[<=120;1000] (max: D/1000)                         under DriveWell100

/* formula 9 */
E[<=120;1000] (max:(distance <= 0))                under DriveWell100

/* formula 10 */
E[<=120;2] (max: 0)                                under DriveWell100

/* formula 11 */
strategy DriveWell10 = minE (D/1000 + (distance <= 0)*10.0) [<=120] {} -> {rVelocityEgo, rVelocityFront, rDistance}: <> time >= 120

/* formula 12 */
saveStrategy("%resultsdir%/DriveWell10.strategy.json", DriveWell10)

/* formula 13 */
E[<=120;1000] (max: D/1000)                          under DriveWell10

/* formula 14 */
E[<=120;1000] (max:(distance <= 0))                 under DriveWell10

/* formula 15 */
E[<=120;2] (max: 0)                                 under DriveWell10

