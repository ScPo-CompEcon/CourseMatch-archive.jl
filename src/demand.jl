"""
    demand(price, pref, budget, capacity)
    demand(price, s::Student)

Compute the total demand for classes based on the optimal individual bundles given preferences, budget and prices, using the `GurobiSolver()`.


## Arguments

Assume that N is the number of students, and C the number of classes that are available to choose from.

- `price` : a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.
- `pref` : an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences. Each of the matrices contained in that array should be a squared matrix of dimension C.
- `budget` : a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.
- `capacity` : a column vector of dimension N x 1, which n-th element is the number of classes student n has to attend.

## Example

* 20 individuals
* 10 classes to choose from
* exactly 3 classes to attend
* NO CROSS PREFERENCES, i.e. Individual preferences are generated as an array of sparse diagonal matrices

```
julia> Ind_pref = []
0-element Array{Any,1}

julia> for i in 1:20
                push!(Ind_pref, 
                sparse(collect(1:10), 
                    collect(1:10), 
                    rand(0:100, 10))
                )
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

julia> price = rand(10)
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

julia> CourseMatch.demand(price, Ind_pref, ind_budget, cap)

julia> d[:ind_demands]
20×10 Array{Int64,2}:
 0  0  0  1  1  0  1  0  0  0
 0  0  0  0  1  1  1  0  0  0
 0  1  0  0  1  1  0  0  0  0
 0  1  0  0  1  1  0  0  0  0
 0  0  0  1  0  1  0  0  0  1
 0  0  0  1  0  0  1  0  1  0
 0  1  0  0  0  0  0  1  0  1
 0  0  1  0  0  0  0  1  1  0
 1  0  0  0  0  1  0  0  1  0
 1  0  0  1  0  0  0  0  1  0
 0  0  1  0  0  0  0  1  1  0
 1  0  0  0  0  0  1  1  0  0
 0  0  1  0  1  1  0  0  0  0
 0  0  0  1  0  0  1  1  0  0
 0  0  0  0  1  1  0  1  0  0
 0  1  0  1  0  0  0  1  0  0
 1  0  0  1  0  1  0  0  0  0
 1  0  0  1  0  1  0  0  0  0
 0  1  1  0  0  0  0  0  0  1
 0  1  0  1  0  0  0  0  0  1

 julia> d[:course_demand]
1×10 Array{Int64,2}:
 5  6  4  9  6  9  5  7  5  4

```

"""
function demand(price, pref, budget, capacity)


	M = length(pref)
    N = size(pref[1],2)  # imposed that all have the same number of preferences.
    demand = zeros(Int,M,N)

	for i in 1:M

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
            demand[i,:] = getvalue(x)
		end

	end

  # add clearing error
  # err = clearing_error(sum(demand,1),chairs,price)


  return Dict(:ind_demands => demand,:course_demand => sum(demand,1),:total=>sum(demand) )
	# return Dict(:ind_demands => demand,:course_demand => sum(demand,1),:total=>sum(demand),:clearing_error=>err )

end
