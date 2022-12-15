## Right no sorry. This isn't a UI library or anything. The color theme is just called that.

colors = 
	(TURQUOISE = colorant"#1abc9c", 
	EMERALD = colorant"#2ecc71", 
	PETER_RIVER = colorant"#3498db", 
	AMETHYST = colorant"#9b59b6", 
	WET_ASPHALT = colorant"#34495e",
	
	GREEN_SEA   = colorant"#16a085", 
	NEPHRITIS   = colorant"#27ae60", 
	BELIZE_HOLE  = colorant"#2980b9", 
	WISTERIA     = colorant"#8e44ad", 
	MIDNIGHT_BLUE = colorant"#2c3e50", 
	
	SUNFLOWER = colorant"#f1c40f",
	CARROT   = colorant"#e67e22",
	ALIZARIN = colorant"#e74c3c",
	CLOUDS   = colorant"#ecf0f1",
	CONCRETE = colorant"#95a5a6",
	
	ORANGE = colorant"#f39c12",
	PUMPKIN = colorant"#d35400",
	POMEGRANATE = colorant"#c0392b",
	SILVER = colorant"#bdc3c7",
	ASBESTOS = colorant"#7f8c8d")



transitioncolors = [colorant"#93d0ff", colorant"#93ffb4", colorant"#FFFFFF"]
transitionlabels = ["Initial", "Reachable", "Not reachable"]

bbshieldlabels = 	["{hit, nohit}", "{hit}", "{}"]
bbshieldcolors = 	[colorant"#ffffff", colorant"#a1eaff", colorant"#ff9178"]


ccshieldcolors=[
	colors.POMEGRANATE, # 000
	colors.PETER_RIVER, # 001
	colors.EMERALD, # 010
	colors.CONCRETE, # 011
	colors.SUNFLOWER, # 100
	colors.TURQUOISE, # 101
	colors.AMETHYST, # 110
	colors.CLOUDS, # 111
]

ccshieldlabels=["No actions", "1 Action", "2 Actions", "All 3 Actions"]

# Used for shielding results figures.
shielding_type_colors = (pre_shielded=colors.GREEN_SEA, no_shield=colors.BELIZE_HOLE, post_shielded=colors.SUNFLOWER, layabout=colors.MIDNIGHT_BLUE)
runs_colors = [colors.PETER_RIVER colors.EMERALD colors.AMETHYST colors.TURQUOISE]