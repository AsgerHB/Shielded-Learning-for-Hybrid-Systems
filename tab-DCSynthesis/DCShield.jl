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

# ╔═╡ bb902940-a858-11ed-2f11-1d6f5af61e4a
begin
	using Pkg
	Pkg.activate("..")
	Pkg.develop("GridShielding")
	using GridShielding
	
	include("../Shared Code/DC-DC Converter.jl")
	include("../Shared Code/FlatUI.jl")
	using Plots
	using PlutoLinks
	using PlutoUI
	using Unzip
	using Printf
	using StatsBase
	TableOfContents()
end

# ╔═╡ 6f5584c1-ea5e-49ee-afc0-25abde4e295a
md"""
# Shielding the DC-DC Converter

From the unpublished paper **Proving and Improving Model Predictive Control of DC-DC Boost Converters.** 

It is similar to, but not quite the same as  [Direct Voltage Control of DC–DC Boost Converters Using Enumeration-Based Model Predictive Control](https://www.semanticscholar.org/paper/Direct-Voltage-Control-of-DC%E2%80%93DC-Boost-Converters-Karamanakos-Geyer/df2d695bb5eb7a856be4a624510135a2c7f10233). 

So it turns out there is no neat trick for transforming DC from one voltage to another, unlike AC where you just need spools with different numbers of windings. I think this figure from the latter paper still describes the basic setup. 

![a circuit with a single inductor, a single switch, and some other stuff. I'm not an electrician.](https://i.imgur.com/MrvFyR3.png)

The mechanics are the following. 
The system chan switch between states on and off, denoted by the control variable $\delta(t)$.


 $R_L, L$ and $C_o$ are constants derived from the physical system. So is $v_s$, the input voltage. I'm pulling those from the UPPAAL model associated with the paper. $R$ is a variable load on the system, bounded between 60 and 80. In the model it can only change by 10 each tick.

![a bunch more lol](https://i.imgur.com/e6Z1VHP.png)
"""

# ╔═╡ e4f088b7-b48a-4c6f-aa36-fc9fd4746d9b
md"""
## Preface
"""

# ╔═╡ 5ae3173f-6abb-4f38-94f8-90300c93d0e9
call(f) = f()

# ╔═╡ 35fbdec7-b673-40a9-8e49-2e19c596b71b
md"""
## Mechanics and Gridification
"""

# ╔═╡ 67d83ab6-8d99-4067-aafc-dee1026eb1dc
m = DCMechanics()

# ╔═╡ 1687a47c-c3f6-4518-ac46-e97b240ad323
md"""
`granularity =` $(@bind granularity NumberField(0.001:0.001:4, default=0.1))
"""

# ╔═╡ a619d4e6-0b40-4819-9c24-62be2b789fad
is_safe(bounds::Bounds, mechanics::DCMechanics) = 		
		is_safe((bounds.lower[1], bounds.lower[2]), mechanics) &&
		is_safe((bounds.upper[1], bounds.upper[2]), mechanics)

# ╔═╡ ae621a99-56e3-4a93-8af0-096c3a6f00f0
begin
	grid = Grid([0.0005, 0.001, 1.0], [
			m.x1_min, 
			m.x2_min - granularity,
			m.R_min
		], [
			m.x1_max + granularity,
			m.x2_max + granularity,
			m.R_max + 1
		])

	initialize!(grid, (b -> is_safe(b, m)))
end

# ╔═╡ be055e02-7ef6-4a63-8c95-d6c2bfdc799a
md"""
Total partitions: **$(length(grid.array))**

Estimated time to compute reachability: $(1/405657 * length(grid.array)) minute
"""

# ╔═╡ 33861602-0e64-4977-9c64-7ae42eb890d4
grid.bounds

# ╔═╡ cfe8387f-a127-4e46-88a6-40d9442fe4b1
md"""
## Simulation Model
"""

# ╔═╡ d2300c36-906c-4351-952a-3a5176338649
randomness_space = Bounds((-m.R_fluctuation,), (m.R_fluctuation,))

# ╔═╡ ce2ecf63-c2dc-4c6b-9a60-1a934e915ba2
md"""
`samples_per_axis_input =` $(@bind samples_per_axis_input NumberField(1:30, default=2))
"""

# ╔═╡ 93664169-7b13-4d17-9658-007d4d5c6c48
samples_per_axis = [samples_per_axis_input, samples_per_axis_input, 1]

# ╔═╡ f81f53ce-d81e-429d-ac80-a3edd2f76eac
md"""
## Some Debug Stuff
"""

# ╔═╡ 9f1c8c62-0ad1-4c93-8f0a-ef0f61f2bcf4
md"""
## Importing Safe Strategy

Optionally, you can import an existing safe strategy.
"""

# ╔═╡ 5ff2a592-e30e-43ad-938e-5396f94f713e
md"""
**Pick your shield:** 

`selected_file` = $(@bind selected_file PlutoUI.FilePicker([MIME("application/octet-stream")]))
"""

# ╔═╡ f589d4eb-5f83-449b-8271-56fc1b008b83
imported_shield = 
	if selected_file !== nothing
		robust_grid_deserialization(selected_file["data"] |> IOBuffer)
	else
		nothing
	end

# ╔═╡ 252ac6f4-ae88-4647-91cc-7f29e0a1a015
md"""
## Synthesising Safe Strategy
"""

# ╔═╡ 084c26b7-2786-4aea-af07-43e6adee06cf
@bind max_steps NumberField(0:1000, default=10)

# ╔═╡ 1e2dcb19-8e61-45b9-a033-0e28406b1511
md"""

Show barbaric transition $(@bind show_tv CheckBox()) 

Select which axes to display. Order is ignored.

$(@bind index_1 Select(
	[1 => "x1",
	2 => "x2",
	3 => "R"]
))
$(@bind index_2 Select(
	[1 => "x1",
	2 => "x2",
	3 => "R"],
	default=2
))
"""

# ╔═╡ bf83ba44-8900-48c8-a172-161337181e41
begin
	xlabel = min(index_1, index_2)
	ylabel = max(index_1, index_2)
	state_variables = Dict(1 => "x1", 2 => "x2", 3 => "R")
	xlabel = state_variables[xlabel]
	ylabel = state_variables[ylabel]
end;

# ╔═╡ 7692cddf-6b37-4be2-847f-afb6d34e44ab
md"""
### Select State to preview

!!! info "Tip"
	This cell affects multiple other cells across the notebook. Drag it around to make interaction easier.

`x1 =` $(@bind x1 NumberField(grid.bounds.lower[1] + granularity:granularity:grid.bounds.upper[1], default=default=m.x1_ref))
`x2 =` $(@bind x2 NumberField(grid.bounds.lower[2] + granularity:granularity:grid.bounds.upper[2], default=default=m.x2_ref))

`R =` $(@bind R NumberField(grid.bounds.lower[3]:1:grid.bounds.upper[3]))

`action =` 
$(@bind action Select(instances(SwitchStatus) |> collect))

"""

# ╔═╡ 5d8cd954-3605-431a-bf85-1a03fa82497d


# ╔═╡ 4d169b72-54f8-4325-adec-f53d18e54fae
md"""
## Check Safety
"""

# ╔═╡ dae2fc1d-38d0-48e1-bddc-3b490648648b
# Probability that the random agents selects the action "off" at any given time
@bind off_chance NumberField(0:0.01:1, default=0.3)

# ╔═╡ 4f01a075-b44b-467c-9f87-55df435b7bdd
random_agent(_...) = sample([on, off], [1 - off_chance, off_chance] |> Weights)

# ╔═╡ 87d7a2f0-4602-489e-8dba-6cd0f71fdad7
# Values v and l are unbounded, but we'd like to clamp them to roughly the bounds of the shield.
function clamp_state(grid::Grid, state)
	x1, x2, R = state
	x1 = clamp(x1, grid.bounds.lower[1], grid.bounds.upper[1] - 0.1*grid.granularity[1])
	x2 = clamp(x2, grid.bounds.lower[2], grid.bounds.upper[2] - 0.1*grid.granularity[2])
	R = clamp(R, grid.bounds.lower[3], grid.bounds.upper[3] - 0.1*grid.granularity[3])
	x1, x2, R
end

# ╔═╡ c6ef755f-e8ac-486c-890a-0613e3bb10e3
function clamp_state(m::DCMechanics, state)
	ϵ = 0.0001
	x1, x2, R = state
	x1 = clamp(x1, 0, m.x1_max + ϵ)
	x2 = clamp(x2, m.x2_min - ϵ, m.x2_max + ϵ)
	R = clamp(R, m.R_min - ϵ, m.R_max + ϵ)
	x1, x2, R
end

# ╔═╡ 04f6c10f-ee06-40f3-969d-9197504c9f61
simulation_function(s, a, r) = clamp_state(m, simulate_point(m, s, a, r))

# ╔═╡ 90efd733-ea84-46c4-80a5-556f23dc4192
simulation_model = SimulationModel(simulation_function, randomness_space, samples_per_axis)

# ╔═╡ 40116c98-2afb-48d8-a7d6-de03c5bc119c
grid, simulation_model; @bind make_shield_button CounterButton("Make Shield")

# ╔═╡ f65de4dd-438b-43c2-9571-adc3fa03fb09
reachability_function = get_barbaric_reachability_function(simulation_model)

# ╔═╡ d57587e2-a9f3-4e10-9679-325f716882e9
if make_shield_button > 0
	reachability_function_precomputed = 
		get_transitions(reachability_function, SwitchStatus, grid)
end

# ╔═╡ 09496aef-95be-43b8-95d1-5cdaa9da50b9
if make_shield_button > 0 && imported_shield === nothing

	## The actual call to make_shield ##
	
	shield, max_steps_reached = 
		make_shield(reachability_function_precomputed, SwitchStatus, grid; max_steps)
	
elseif imported_shield === nothing
	shield, max_steps_reached = grid, true
else
	shield, max_steps_reached = imported_shield, false
end

# ╔═╡ 8751340a-f41a-46fa-8f6d-cc9ca132e260
partition = box(something(shield, grid), (x1, x2, R))

# ╔═╡ ad6bc72c-f9f2-41a7-958b-a4be73a018d6
is_safe(Bounds(partition), m)

# ╔═╡ 5d35a493-0195-46f7-bdf6-013fde056a1e
sample_count = (length(SupportingPoints(samples_per_axis, partition)))

# ╔═╡ 7749a8ca-2f38-41c7-9372-df06ce54b919
Bounds(partition)

# ╔═╡ c6aec984-3963-41f3-9281-e267d1c8ac78
supporting_points = SupportingPoints(samples_per_axis, partition)

# ╔═╡ 31699662-ddfc-45a8-b963-f0b03b7c71c2
supporting_points |> collect

# ╔═╡ b83a55ee-f2a3-4b0b-8e0a-12dc6caf5075
possible_outcomes(simulation_model, partition, action)

# ╔═╡ cd732487-5c1b-487e-b037-4523a7389365
[Partition(grid, i) |> Bounds 
	for i in reachability_function(partition, action)]

# ╔═╡ d099b12b-9e8e-482f-82ed-a4681a424d2e
slice = let
	slice = Any[i for i in partition.indices]
	slice[index_1] = Colon()
	slice[index_2] = Colon()
	slice
end

# ╔═╡ 56781a46-51a5-425d-aea8-bcfd4820da88
if max_steps_reached
md"""
!!! danger "NB"
	Synthesis not complete. 

	Either synthesis hasn't started, or `max_steps` needs to be increased to obtain an infinite-horizon strategy.
"""
end

# ╔═╡ f6bab622-4b1d-41ec-ae54-61915fca3b2c
reachability_function′(partition, a) = begin
	result = reachability_function(partition, a)
	result = map(r -> Partition(partition.grid, r), result)
	result = map(r -> (dcshieldcolors[get_value(r)+1], (Bounds(r))), result)
end

# ╔═╡ 7358338f-47d9-4cb1-a868-f89b0162e72d
reachability_function′(partition, off)

# ╔═╡ 258ec4cf-4193-4b14-bf4c-53f83eca96ae
reachability_function′(partition, on)

# ╔═╡ fd2b4c23-e373-43e7-9a4f-63203ef2b83b
let
	draw(something(shield, grid), slice,
		legend=:outerright, 
		colors=dcshieldcolors,
		#show_grid=true,
		color_labels=dcshieldlabels;
		xlabel, ylabel)
	
	if show_tv
		draw_barbaric_transition!(simulation_model, partition, action, slice)
	end
	plot!()
end

# ╔═╡ 186fb459-c758-473f-8510-e665cf3da7a8
function shielded(shield, policy)
	return (state) -> begin
		suggested = policy(state)
		state = clamp_state(shield, state)
		partition = box(shield, state)
		allowed = int_to_actions(SwitchStatus, get_value(partition))
		if state ∉ shield || length(allowed) == 0 || suggested ∈ allowed
			return suggested
		else
			corrected = rand(allowed)
			return corrected
		end
	end
end

# ╔═╡ a57c6670-6d88-4119-b5b1-7509a8806dae
shielded(something(shield, grid), (_...) -> action)((x1, x2, R))

# ╔═╡ 1b447b3e-0565-4dc5-b679-5102c946dec2
shielded_random_agent = shielded(shield, random_agent)

# ╔═╡ fdfa1b59-217e-4504-9d4f-2ad44c39cfd8
let
	draw(shield, [:, :, 2, 1],
		colorbar=:right, 
		colors=dcshieldcolors,
		color_labels=dcshieldlabels)

	for _ in 1:1
		trace = 
			simulate_trace(m, initial_state, shielded_random_agent, duration=120)
		
		plot!(trace.x1s, trace.x2s,
			line=(colors.WET_ASPHALT, 2),
			label=nothing)
	end
	plot!(xlabel="x1", ylabel="x2")
end

# ╔═╡ 811efa40-bf3b-4597-b7dd-72862e63b8c9
initial_state

# ╔═╡ aeba4953-dee5-4810-a3de-0fc191711e16
begin
	plot()
	for i in 1:1
		trace = 
			simulate_trace(m, (0.35, 15., 60), shielded_random_agent, duration=120)
		
		plot!(trace.elapsed, trace.x2s,
			line=(colors.SUNFLOWER, 2),
			label="voltage")
		
		plot!(trace.elapsed, trace.x1s,
			line=(colors.ALIZARIN, 2),
			label="current")
	end
	hline!([m.x2_min, m.x2_max], color=colors.WET_ASPHALT, label="safety constraints")
	plot!(xlabel="t (µs)", legend=:outerright)
end

# ╔═╡ d77f23be-3a54-4c48-ab6d-b1c31adc3e25
unsafe, total, unsafe_trace = count_unsafe_traces(m, shielded_random_agent, run_duration=120, runs=1000)

# ╔═╡ 150d8707-e8ef-4476-9378-9dd1c63036bf
if unsafe > 0
Markdown.parse("""
!!! danger "Shield is Unsafe"
    There were $unsafe safety violations during the $total runs.
""")
else
Markdown.parse("""
!!! success "Shield is Safe"
    There were no safety violations during the $total runs.
""")
end

# ╔═╡ ac138da0-fd64-4e35-ab26-e5803fa2d9b5
cost(m, shielded_random_agent)

# ╔═╡ e8d8db08-50d9-4cca-8cbe-aac6ea0132e3
cost(m, random_agent)

# ╔═╡ e5a18013-48a1-4329-b238-65a606a82c9b
if unsafe_trace !== nothing
	@bind state_index NumberField(1:length(unsafe_trace.actions), default=2)
end

# ╔═╡ f0a96c74-c73b-4763-992e-73d4aa542976
if unsafe_trace != nothing let

	(;x1s, x2s, Rs, actions) = unsafe_trace
	unsafe_trace′ = [x1s, x2s, Rs, actions]

	x1, x2, R, a = x1s[state_index], x2s[state_index], Rs[state_index],  actions[state_index]

	partition = box(shield, clamp_state(shield, (x1, x2, R)))
	
	slice = Any[i for i in partition.indices]
	slice[index_1] = Colon()
	slice[index_2] = Colon()
	slice

	draw(shield, slice,
		legend=:outerright, 
		colors=dcshieldcolors,
		color_labels=dcshieldlabels)
	xs, ys = unsafe_trace′[min(index_1, index_2)], unsafe_trace′[max(index_1, index_2)]
	x, y = xs[state_index], ys[state_index]
	
	plot!(xs, ys,
		#xlims=(shield.bounds.lower[1], shield.bounds.upper[1]),
		#ylims=(shield.bounds.lower[2], shield.bounds.upper[2]),
		line=(colors.WET_ASPHALT, 2);
		xlabel, ylabel)
	
	scatter!([x], [y],
		marker=(colors.EMERALD, 5, :+),
		msw=4)
end end

# ╔═╡ 4af0b349-5894-4da5-8c3b-9fbc466d94f5
if unsafe_trace != nothing let 
	(;x1s, x2s, Rs, actions) = unsafe_trace
	
	shielded_random_agent((x1s[state_index], x2s[state_index], Rs[state_index])),  actions[state_index - 1]
end end

# ╔═╡ 16598016-eb21-43da-a45b-bd09692125ca
call(() -> begin
	
	buff = IOBuffer(sizehint=length(shield.array))
	robust_grid_serialization(buff, shield)
	shield_description =  "samples $sample_count granularity $(grid.granularity).shield"
	
	md"""
	## Save
	Save as serialized julia object
	
	$(DownloadButton(buff.data, shield_description))
	"""
end)

# ╔═╡ 63b217ad-bb2c-420b-b327-2c9a28be0a90
let 
	buff = IOBuffer()
	
	println(buff, get_c_library_header(shield, "Samples used: $samples_per_axis"))
	
	md"""
	Dump into a C file (hard-coded into a `const char[]`)
	
	$(DownloadButton(buff.data, "shield_dump.c"))
	"""
end

# ╔═╡ Cell order:
# ╟─6f5584c1-ea5e-49ee-afc0-25abde4e295a
# ╟─e4f088b7-b48a-4c6f-aa36-fc9fd4746d9b
# ╠═bb902940-a858-11ed-2f11-1d6f5af61e4a
# ╠═5ae3173f-6abb-4f38-94f8-90300c93d0e9
# ╟─35fbdec7-b673-40a9-8e49-2e19c596b71b
# ╠═67d83ab6-8d99-4067-aafc-dee1026eb1dc
# ╟─1687a47c-c3f6-4518-ac46-e97b240ad323
# ╟─be055e02-7ef6-4a63-8c95-d6c2bfdc799a
# ╠═ae621a99-56e3-4a93-8af0-096c3a6f00f0
# ╠═33861602-0e64-4977-9c64-7ae42eb890d4
# ╠═a619d4e6-0b40-4819-9c24-62be2b789fad
# ╠═ad6bc72c-f9f2-41a7-958b-a4be73a018d6
# ╟─cfe8387f-a127-4e46-88a6-40d9442fe4b1
# ╠═d2300c36-906c-4351-952a-3a5176338649
# ╟─ce2ecf63-c2dc-4c6b-9a60-1a934e915ba2
# ╠═93664169-7b13-4d17-9658-007d4d5c6c48
# ╠═5d35a493-0195-46f7-bdf6-013fde056a1e
# ╠═04f6c10f-ee06-40f3-969d-9197504c9f61
# ╠═90efd733-ea84-46c4-80a5-556f23dc4192
# ╟─f81f53ce-d81e-429d-ac80-a3edd2f76eac
# ╠═8751340a-f41a-46fa-8f6d-cc9ca132e260
# ╠═7749a8ca-2f38-41c7-9372-df06ce54b919
# ╠═c6aec984-3963-41f3-9281-e267d1c8ac78
# ╠═31699662-ddfc-45a8-b963-f0b03b7c71c2
# ╠═b83a55ee-f2a3-4b0b-8e0a-12dc6caf5075
# ╠═cd732487-5c1b-487e-b037-4523a7389365
# ╟─9f1c8c62-0ad1-4c93-8f0a-ef0f61f2bcf4
# ╟─5ff2a592-e30e-43ad-938e-5396f94f713e
# ╠═f589d4eb-5f83-449b-8271-56fc1b008b83
# ╟─252ac6f4-ae88-4647-91cc-7f29e0a1a015
# ╟─40116c98-2afb-48d8-a7d6-de03c5bc119c
# ╠═f65de4dd-438b-43c2-9571-adc3fa03fb09
# ╠═d57587e2-a9f3-4e10-9679-325f716882e9
# ╠═09496aef-95be-43b8-95d1-5cdaa9da50b9
# ╟─56781a46-51a5-425d-aea8-bcfd4820da88
# ╠═084c26b7-2786-4aea-af07-43e6adee06cf
# ╟─1e2dcb19-8e61-45b9-a033-0e28406b1511
# ╟─d099b12b-9e8e-482f-82ed-a4681a424d2e
# ╟─bf83ba44-8900-48c8-a172-161337181e41
# ╟─fd2b4c23-e373-43e7-9a4f-63203ef2b83b
# ╟─7692cddf-6b37-4be2-847f-afb6d34e44ab
# ╠═5d8cd954-3605-431a-bf85-1a03fa82497d
# ╠═f6bab622-4b1d-41ec-ae54-61915fca3b2c
# ╠═7358338f-47d9-4cb1-a868-f89b0162e72d
# ╠═258ec4cf-4193-4b14-bf4c-53f83eca96ae
# ╟─4d169b72-54f8-4325-adec-f53d18e54fae
# ╠═dae2fc1d-38d0-48e1-bddc-3b490648648b
# ╠═4f01a075-b44b-467c-9f87-55df435b7bdd
# ╠═87d7a2f0-4602-489e-8dba-6cd0f71fdad7
# ╠═c6ef755f-e8ac-486c-890a-0613e3bb10e3
# ╠═186fb459-c758-473f-8510-e665cf3da7a8
# ╠═a57c6670-6d88-4119-b5b1-7509a8806dae
# ╠═1b447b3e-0565-4dc5-b679-5102c946dec2
# ╠═fdfa1b59-217e-4504-9d4f-2ad44c39cfd8
# ╠═811efa40-bf3b-4597-b7dd-72862e63b8c9
# ╟─aeba4953-dee5-4810-a3de-0fc191711e16
# ╠═d77f23be-3a54-4c48-ab6d-b1c31adc3e25
# ╟─150d8707-e8ef-4476-9378-9dd1c63036bf
# ╠═ac138da0-fd64-4e35-ab26-e5803fa2d9b5
# ╠═e8d8db08-50d9-4cca-8cbe-aac6ea0132e3
# ╠═e5a18013-48a1-4329-b238-65a606a82c9b
# ╟─f0a96c74-c73b-4763-992e-73d4aa542976
# ╠═4af0b349-5894-4da5-8c3b-9fbc466d94f5
# ╟─16598016-eb21-43da-a45b-bd09692125ca
# ╟─63b217ad-bb2c-420b-b327-2c9a28be0a90
