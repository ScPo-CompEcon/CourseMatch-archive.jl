#= Demand function =#

using JuMP, Cbc, Gurobi

## BASIC CASE : no preferences for couples ##


# Simulate some data

ind_pref = []
for i in 1:20
	push!(ind_pref, rand(0:100, 10))
end
ind_budget = rand(150:200, 20)
price = rand(Float32, 10)

a=1

# Initialize demand

Demand = []

# Algorithm

#= This algorithm finds the best class allocation, it has to be
given the preferences, the price vector, the individual allocated budget
and the number of classes one is to take. =#

for i in 1:20

	let
		# Maximization problem
		m = Model(solver=CbcSolver())

		@variable(m, x[1:10], Bin)
		pref = ind_pref[i]
		price = price
		capacity = 3 #number of classes one should attend
		budget = ind_budget[i]

		# Objective: maximize utility
		@objective(m, Max, dot(pref, x))

		# Constraints:

		#Should have exactly 3 classes
		@constraint(m, sum(x) <= capacity)

		#Should not spend more than one's budget
		@constraint(m,  dot(price, x) <= budget)

		# Solve problem using MIP solver
		status = solve(m)

		push!(Demand, getvalue(x))
	end

end

# Total_demand for each class

Total_demand = sum(Demand)

# Surplus


## MAIN CASE : preferences for couples

#= In that case the objective becomes quadratic. It seems that the CBC
solver cannot handle quadratic objectives, so I switched to gurob, which can. =#

using Gurobi

A = sparse([1; 1; 2; 2; 2; 3; 4], [1; 4; 2; 3; 4; 3; 4], [80, 200, 50, -200, -200, 30, 75])

demand = []

let
	# Maximization problem
	m = Model(solver=GurobiSolver())
	@variable(m, x[1:4], Bin)

	pref = A
	price = price[1:4]
	capacity = 2
	budget = ind_budget[1]

	# Objective: maximize utility
	@objective(m, Max, vecdot(x'*pref, x))

	# Constraints:

	#Should have exactly 3 classes
	@constraint(m, sum(x) <= capacity)

	#Should not spend more than one's budget
	@constraint(m,  dot(price, x) <= budget)

	# Solve problem using MIP solver
	status = solve(m)
	push!(demand, getvalue(x))
end
