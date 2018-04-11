module CourseMatch

	VERSION = VersionNumber(0,0,0)

# package code goes here

#= Demand function =#

## Allocation algorithm

#= This algorithm finds the best class allocation, it has to be
given the preferences, the price vector, the individual allocated budget
and the number of classes one is to take. =#


## BASIC CASE : no preferences for couples ##

## For one individual

let
	# Maximization problem
	m = Model(solver=CbcSolver())
	@variable(m, x[1:10], Bin)
	pref = rand(0:100, 10)
	price = rand(Float32, 10)
	capacity = 3
	budget = 200
	# Objective: maximize profit
	@objective(m, Max, dot(pref, x))
	# Constraint: can carry all
	@constraint(m, sum(x) <= capacity)
	@constraint(m,  dot(price, x) <= budget)
	# Solve problem using MIP solver
	status = solve(m)
	println("Objective is: ", getobjectivevalue(m))
	println("Solution is:")
	for i = 1:10
	print("x[$i] = ", getvalue(x[i]))
	#println(", p[$i]/w[$i] = ", profit[i]/weight[i])
	end
end

end # module
