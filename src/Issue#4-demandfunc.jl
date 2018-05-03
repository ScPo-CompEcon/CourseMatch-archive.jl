"""
    demand(price, pref, budget, capacity)

Compute the total demand for classes based on the optimal individual bundles given preferences,
 budget and prices, thanks to GurobiSolver.


# Arguments

Assume that N is the number of students, and C the number of classes that are available to choose from.

- `price` : a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.

- `pref` : an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences.
	Each of the matrices contained in that array should be a squared matrix of dimension C.

- `budget` : a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.

- `capacity` : a column vector of dimension N x 1, which n-th element is the number of classes student n has to attend.

# Example

20 individuals, 10 classes to choose from, exactly 3 classes to attend, NO CROSS PREFERENCES
(Individual preferences are generated as an array of sparse diagonal matrices

```
julia> Ind_pref = []
0-element Array{Any,1}

julia> for i in 1:20
               push!(Ind_pref, sparse(collect(1:10), collect(1:10), rand(0:100, 10)))
       end

julia> Ind_pref
20-element Array{Any,1}:

  [1 ,  1]  =  63
  [2 ,  2]  =  51
  [3 ,  3]  =  39
  [4 ,  4]  =  85
  [5 ,  5]  =  35
  [6 ,  6]  =  60
  [7 ,  7]  =  84
  [8 ,  8]  =  96
  [9 ,  9]  =  61
  [10, 10]  =  56

  ⋮

  [1 ,  1]  =  30
  [2 ,  2]  =  9
  [3 ,  3]  =  9
  [4 ,  4]  =  58
  [5 ,  5]  =  25
  [6 ,  6]  =  82
  [7 ,  7]  =  0
  [8 ,  8]  =  75
  [9 ,  9]  =  94
  [10, 10]  =  36

julia> ind_budget = rand(150:200, 20)
20-element Array{Int64,1}:
  162
  195
  ⋮
  193

julia> price = rand(Float32, 10)
10-element Array{Float32,1}:
  0.786705
  0.735436
  ⋮
  0.880273

julia> cap = fill(3, 20)
20-element Array{Int64,1}:
  3
  ⋮
  3

julia> demand(price, Ind_pref, ind_budget, cap)
```

"""
...
function demand(price, pref, budget, capacity)

	demand = []

	M = length(pref)

	for i in 1:M

		N = size(pref[i])[1]

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
