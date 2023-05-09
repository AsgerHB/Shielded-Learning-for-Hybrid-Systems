### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ bdb61d68-2ac9-11ed-1b20-9dc154fc45d0
begin
	using Pkg
	Pkg.activate("..")
	Pkg.develop("GridShielding")
	using GridShielding
	
	using JSON
	using PlutoUI
	using Random
	using Plots
	using Serialization
	using StatsBase
	using NaturalSort
	using Measures
	using Unzip
	include("../Shared Code/FlatUI.jl")
	include("../Shared Code/OilPump.jl")
	include("../Shared Code/OPShielding.jl")	
end;

# ╔═╡ 12556d17-f66f-4db3-8718-3576b8a2c8dc
call(f) = f()

# ╔═╡ faf6e126-51f6-47ad-a02a-f673223b2600
fast_color, slow_color = enby[1], enby[3]

# ╔═╡ 8894e942-b6f6-4893-bfea-ebaa2f9c58f0
md"""
## Importing the policy:
"""

# ╔═╡ c426cf95-81ed-4c70-96a1-d46e05e29ddb
md"""
**Pick your shield:** 

`selected_shield` = $(@bind selected_shield PlutoUI.FilePicker([MIME("application/octet-stream")]))
"""

# ╔═╡ c870988d-96aa-4114-9901-35472f341d16
if selected_shield == nothing
	md"""
!!! danger "Error"
	# Please select file
"""
end

# ╔═╡ f334b30a-7963-4314-8a26-4f8e0c493ce9
imported_shield = 
	if selected_shield !== nothing
		robust_grid_deserialization(selected_shield["data"] |> IOBuffer)
	else
		nothing
	end

# ╔═╡ 534968b3-b361-41e0-8e2a-c3ec9e73eef4
function show_strategy_info(s::Dict)
	pointvars = s["pointvars"]
	pointvars = join(pointvars, ", ")
	statevars = s["statevars"]
	statevars = join(statevars, ", ")
	
	locations(dict) = join(["$k: `$v`" 
		for (k, v) in sort(dict, lt=natural)
	], ", ")
	
	locationnames = s["locationnames"]
	
	locationnames = join(["       - $k: $(locations(v))"
		for (k, v) in locationnames
	], "\n\n")

	actions = s["actions"]
	actions = sort(actions, lt=natural)
	actions = join(["      - $k: `$v`"
		for (k, v) in actions
	], "\n\n")

	s["type"] != "state->regressor" && @error("Strategy type not supported")
	s["version"] != 1.0 && @error("Strategy version not supported")
	
	Markdown.parse("""
	!!! info "Strategy { $statevars } -> { $pointvars }"

		`statevars`: $(statevars == "" ? "none" : statevars)
	
		`pointvars`: $(pointvars == "" ? "none" : pointvars)
	
		**Location names:**
	
	$(locationnames)

		**Actions**

	$actions
	""")
end

# ╔═╡ b3e2a24a-fab6-414e-be8b-351a0e7d1b1c
md"""
## Methods to read the policy file
"""

# ╔═╡ cadb990a-483b-4745-aad2-38ec784fbed4
function get_action_names(file)
	jsondict = file["data"] |> IOBuffer |> JSON.parse
	action_names = jsondict["actions"]
end

# ╔═╡ 1f8a4dda-3007-47bd-82da-bcc5463b0a23
function get_variable_names(file)
	jsondict = file["data"] |> IOBuffer |> JSON.parse
	action_names = vcat(jsondict["pointvars"], jsondict["statevars"])
end

# ╔═╡ 5204d97e-6e04-4525-818b-a7ed642aec0d
# Traverse the "simpletree" which makes a prediction on the continuous statevars for the regressor's action
function traverse_simpletree(regressor, statevars)
	# Base case
	if typeof(regressor) <: Number
		return regressor
	end

	# Recursion
	var_index = regressor["var"] + 1 # Julia indexes start at 1
	var = statevars[var_index]
	bound = regressor["bound"]
	if var >= bound
		traverse_simpletree(regressor["high"], statevars)
	else
		traverse_simpletree(regressor["low"], statevars)
	end
end

# ╔═╡ 7f840af3-bff8-4548-9d31-cf3c64fa9faf
function get_action(regressor, state)
	actions = [k for (k, _) in regressor]

	lowest_outcome = Inf
	cheapest_action = nothing
	for action in actions
		outcome = traverse_simpletree(regressor[action], state)
		if outcome < lowest_outcome
			lowest_outcome = outcome
			cheapest_action = action
		end
	end
	parse(Int, cheapest_action)
end

# ╔═╡ 29a9d1e2-b0d0-46f2-bbff-ba30f13d3ac0
md"""
### Testing the policy

Get policy from selected file, then apply it to a state.
"""

# ╔═╡ 47a9daed-792b-4b75-8208-3dcf46ede4c5
md"""
## Drawing the policy
Draw a 2D policy
"""

# ╔═╡ f969579d-e392-4dce-88ba-6a5da83b599f
function draw(policy::Function, x_min, x_max, y_min, y_max, G; colors=[:blue, :yellow], actions=["action1", "action2"], plotargs...)
	size_x, size_y = Int((x_max - x_min)/G), Int((y_max - y_min)/G)
	matrix = Matrix(undef, size_x, size_y)
	for i in 1:size_x
		for j in 1:size_y
			x, y = i*G - G + x_min, j*G - G + y_min

			matrix[i, j] = policy([x, y])
		end
	end
	x_tics = G+x_min:G:x_max
	y_tics = G+y_min:G:y_max
	middle_x, middle_y = [(x_max - x_min)/2 + x_min], [(y_max - y_min)/2 + y_min]
	plot(;plotargs...)
	for (a, c) in zip(actions, colors)
		scatter!(
			middle_x, middle_y, # Place the dummy points right in the middle so they get hidden.
			markerstrokewidth=0,
			c=c, label=a)
	end
	heatmap!(x_tics, y_tics,
		    transpose(matrix),
			colorbar=nothing,
			c=colors)
end

# ╔═╡ a68cfc1d-e3fd-43aa-8eea-97615713e0a4
function draw_expected(regressors, action, x_min, x_max, y_min, y_max, G; plotargs...)
	size_x, size_y = Int((x_max - x_min)/G), Int((y_max - y_min)/G)
	matrix = Matrix(undef, size_x, size_y)
	for i in 1:size_x
		for j in 1:size_y
			x, y = i*G - G + x_min, j*G - G + y_min

			matrix[i, j] = traverse_simpletree(regressors[action], (x, y))
		end
	end
	x_tics = G+x_min:G:x_max
	y_tics = G+y_min:G:y_max
	
	heatmap(x_tics, y_tics,
		    transpose(matrix);
			plotargs...)
end

# ╔═╡ db418782-45c3-4724-8b09-4e9ab151f882
@bind p Select([0, 1])

# ╔═╡ 1a27105e-58d5-4dc2-bb7e-f7392a39c900
function get_policy(file)
	jsondict = file["data"] |> IOBuffer |> JSON.parse
	regressor = jsondict["regressors"]["($p)"]["regressor"]

	policy = (state) -> get_action(regressor, state)
end

# ╔═╡ eeebe049-8b0b-4e3e-8cb2-4ee89e241273
md"""
**Exported UPPAAL STRATEGO strategy:** 

`selected_strategy` = $(@bind selected_strategy PlutoUI.FilePicker([MIME("application/json")]))
"""

# ╔═╡ 79fb04f7-2d45-454f-89c5-7312d4aeadde
imported_policy = get_policy(selected_strategy)

# ╔═╡ 9a3af469-7dc0-4d29-a375-bdc79415e950
jsondict = selected_strategy["data"] |> IOBuffer |> JSON.parse

# ╔═╡ 1c8b2b93-8a23-4717-99a1-6d0cd8fa56b1
show_strategy_info(jsondict)

# ╔═╡ f0806bbf-7a71-4d96-81dc-436d009cc9de
draw_expected′(action, title) = 
	draw_expected(jsondict["regressors"]["($p)"]["regressor"], action, 
		0, 20, 
		4, 26,
		0.05,
		xlabel="t",
		ylabel="v",
		colorbar_title="expected cost",
		clims=(100, 250),
		color=cgrad(:roma, 10, categorical=true, scale=:linear),
		title=title,
		legend=:topleft)

# ╔═╡ 84e98403-b4f7-45ed-9638-d2d5fefec26a
get_action_names(selected_strategy)

# ╔═╡ 7e58ef81-3242-4b21-8adc-c8f704954d80
get_variable_names(selected_strategy)

# ╔═╡ c8b9241e-eb92-468d-9452-ee51585f5488
test_policy = get_policy(selected_strategy)

# ╔═╡ 338a7dce-c680-421c-af11-716f6820e9b3
begin
	draw(test_policy, 0, 20, 4, 26, 0.1,
		#size=(300, 200),
		colors=[slow_color, fast_color],
		actions=["off", "on"],
		xlabel="t",
		ylabel="v",
		margin=2mm,
		legend=:topleft)
end

# ╔═╡ 6dd7d4a4-e7df-4c82-bb48-edc0f8ff18ab
begin
	draw_expected′("0", "off")
	plot!(x -> consumption_rate(x)*5 + 5, line=(2, colors.CLOUDS))
end

# ╔═╡ 14fe97ea-97fb-42bc-b0e3-4162b4a48b71
begin
	draw_expected′("1", "on")
	plot!(x -> consumption_rate(x)*5 + 5, line=(2, colors.CLOUDS))
end

# ╔═╡ 596dfcee-99dc-44c6-affe-c5ddef76d90c
md"""
# Shielding the Policy
"""

# ╔═╡ 0856b055-2c75-47d6-8bfb-db2d4a2cf885
imported_shield

# ╔═╡ 2283f773-d6c8-4cf8-b7ab-f1e30b0bb8dd
begin
	shielded_policy_raw = shielded(imported_shield, x -> PumpStatus(test_policy(x)))
	shielded_policy(s) = begin
		t, v = s
		shielded_policy_raw((t, v, p, -0.00001))
	end
end

# ╔═╡ 7d3699f3-94ba-4c38-b4fb-d985e7326595
test_policy(initial_state)

# ╔═╡ 910e8fb3-c026-4b7d-9408-7eb88989268f
shielded_policy(initial_state)

# ╔═╡ 825720f8-186c-4f11-996b-b7ee2f476629
m = OPMechanics()

# ╔═╡ a848cce7-f2f9-41a2-8dd7-82383287e793
# ╠═╡ disabled = true
#=╠═╡
begin
	error("Cannot show trace for this experiment. The pump-status p is constant for shielded_policy. This works for creating a visualisation, but not for simulating a concrete trace. ")
	plot()
	trace = simulate_trace(
		m, initial_state, 
		shielded_policy,
		duration=120)
	plot!(trace.elapsed, trace.vs, 
		label="trace",
		line=(3, colors.WET_ASPHALT))
end
  ╠═╡ =#

# ╔═╡ 545132b9-ba7c-40dc-ae44-8551113c18dd


# ╔═╡ 9e62968a-eaa0-48d9-9842-40df2849a108
begin
	draw(s -> (shielded_policy(s) |> Int), 0, 20, 4, 26, 0.1,
		#size=(300, 200),
		colors=[slow_color, fast_color],
		actions=["off", "on"],
		xlabel="t",
		ylabel="v",
		margin=2mm,
		legend=:topleft)
end

# ╔═╡ Cell order:
# ╠═bdb61d68-2ac9-11ed-1b20-9dc154fc45d0
# ╠═12556d17-f66f-4db3-8718-3576b8a2c8dc
# ╠═faf6e126-51f6-47ad-a02a-f673223b2600
# ╟─8894e942-b6f6-4893-bfea-ebaa2f9c58f0
# ╟─c870988d-96aa-4114-9901-35472f341d16
# ╟─c426cf95-81ed-4c70-96a1-d46e05e29ddb
# ╟─f334b30a-7963-4314-8a26-4f8e0c493ce9
# ╠═79fb04f7-2d45-454f-89c5-7312d4aeadde
# ╠═9a3af469-7dc0-4d29-a375-bdc79415e950
# ╟─534968b3-b361-41e0-8e2a-c3ec9e73eef4
# ╟─1c8b2b93-8a23-4717-99a1-6d0cd8fa56b1
# ╟─b3e2a24a-fab6-414e-be8b-351a0e7d1b1c
# ╠═1a27105e-58d5-4dc2-bb7e-f7392a39c900
# ╟─cadb990a-483b-4745-aad2-38ec784fbed4
# ╠═84e98403-b4f7-45ed-9638-d2d5fefec26a
# ╟─1f8a4dda-3007-47bd-82da-bcc5463b0a23
# ╠═7e58ef81-3242-4b21-8adc-c8f704954d80
# ╠═7f840af3-bff8-4548-9d31-cf3c64fa9faf
# ╠═5204d97e-6e04-4525-818b-a7ed642aec0d
# ╟─29a9d1e2-b0d0-46f2-bbff-ba30f13d3ac0
# ╠═c8b9241e-eb92-468d-9452-ee51585f5488
# ╟─47a9daed-792b-4b75-8208-3dcf46ede4c5
# ╟─f969579d-e392-4dce-88ba-6a5da83b599f
# ╟─338a7dce-c680-421c-af11-716f6820e9b3
# ╟─a68cfc1d-e3fd-43aa-8eea-97615713e0a4
# ╠═f0806bbf-7a71-4d96-81dc-436d009cc9de
# ╠═db418782-45c3-4724-8b09-4e9ab151f882
# ╟─eeebe049-8b0b-4e3e-8cb2-4ee89e241273
# ╠═6dd7d4a4-e7df-4c82-bb48-edc0f8ff18ab
# ╠═14fe97ea-97fb-42bc-b0e3-4162b4a48b71
# ╟─596dfcee-99dc-44c6-affe-c5ddef76d90c
# ╠═0856b055-2c75-47d6-8bfb-db2d4a2cf885
# ╠═2283f773-d6c8-4cf8-b7ab-f1e30b0bb8dd
# ╠═7d3699f3-94ba-4c38-b4fb-d985e7326595
# ╠═910e8fb3-c026-4b7d-9408-7eb88989268f
# ╠═825720f8-186c-4f11-996b-b7ee2f476629
# ╠═a848cce7-f2f9-41a2-8dd7-82383287e793
# ╠═545132b9-ba7c-40dc-ae44-8551113c18dd
# ╠═9e62968a-eaa0-48d9-9842-40df2849a108
