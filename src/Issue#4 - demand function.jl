#= Demand function =#

## Allocation algorithm

#= This algorithm finds the best class allocation, it has to be
given the preferences, the price vector, the individual allocated budget
and the number of classes one is to take. =#


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

for i in 1:20

	let
		# Maximization problem
		m = Model(solver=CbcSolver())
		@variable(m, x[1:10], Bin)
		pref = ind_pref[i]
		price = price
		capacity = 3
		budget = ind_budget[i]
		# Objective: maximize profit
		@objective(m, Max, dot(pref, x))
		# Constraint: can carry all
		@constraint(m, sum(x) <= capacity)
		@constraint(m,  dot(price, x) <= budget)
		# Solve problem using MIP solver
		status = solve(m)
		println("Objective is: ", getobjectivevalue(m))
		println("Solution is:")
		push!(Demand, getvalue(x))
	end

end

Total_demand = sum(Demand)
