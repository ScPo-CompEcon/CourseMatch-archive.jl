#= Demand function =#


#= Assume that N is the number of students, and C the number of classes that are available to choose from.

The argument to the *demand* function defined above should be such that :
	-> *price* is a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.

	-> *pref* is an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences. Each of the matrices contained in that array should be a squared matrix of dimension C.

	-> *budget* is a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.

	-> *capacity* is a column vector of dimension N x 1, which n-th element is the number of classes student n has to attend. =#

function demand(price, pref, budget, capacity)

	demand = []

	M = length(pref)

	for i in 1:M

		N = size(Ind_pref[i])[1]

		let
			# Maximization problem
			m = Model(solver=GurobiSolver())

			@variable(m, x[1:N], Bin)

			# Objective: maximize utility
			@objective(m, Max, x'*pref[i]*x)

			# Constraints:

			#Should have exactly 3 classes
			@constraint(m, sum(x) == capacity[i])

			#Should not spend more than one's budget
			@constraint(m,  dot(price, x) <= budget[i])

			# Solve problem using MIP solver
			status = solve(m)
			push!(demand, getvalue(x))
		end

	end

	return Dict("ind_demands" => demand,
					"total_demand" => sum(demand) )

end


######

## Example : 20 individuals, 10 classes to choose from, exactly 3 classes to attend, NO CROSS PREFERENCES

# Individual preferences are generated as an array of sparse diagonal matrices

Ind_pref = []
for i in 1:20
	push!(Ind_pref, sparse(collect(1:10), collect(1:10), rand(0:100, 10)))
end

# Individual budget

ind_budget = rand(150:200, 20)

# Price vector

price = rand(Float32, 10)

# Capacity vector

cap = fill(3, 20)

# Function application

demand(price, Ind_pref, ind_budget, cap)

######
