# How Reinforcement Learning for Multi-ball is Affected by Shielding

This experiment applies to the multi-ball variant of the bouncing ball problem. The player is given an opportunity every 0.1 seconds to hit the balls or not. 

In this version of Multi-ball, the hit action impacts every ball that can be hit, with no need to choose which ball to target. Like in the single Bouncing Ball problem, a ball cannot be hit if it's position is below 4m, or its velocity is below -4m/s.

The experiment has the following configurations:

- **Shielded Layabout** The shield is applied to a basic "agent", which simply takes the most unsafe action no matter the input. For the Random Walk, this simply entails always going slow. This creates a strategy fully dictated by the shield. 
- **No Shield** An agent is trained with no shield applied, receiving a penalty d on runs that violate the safety property. 
- **Post-shielded** A shield is applied to the same learning agents, that were trained and evaluated in the No Shield model. This means that the agents have been trained without a shield, but are subsequently being shielded during the evaluation phase. 
- **Pre-shielded** The Q-learning agents were trained with the shield in place. If the shield intervenes, it apppears to the agent that it’s suggested action has the outcome of the shielded action.

Run from parent directory as 

	julia "fig-MB3BShieldingResultsGroup/Run Experiment"



It is possible to use the command line argument `--shield` to provide a specific nondeterministic strategy, to use for shielding in the experiment. 
This also shaves 50 minutes off the runtime, since a new shield will have to be synthesised and saved otherwise. 
Example: `--shield ~/Results/tab-BBSynthesis/Exported Strategies/400 Samples 0.01 G.shield`
