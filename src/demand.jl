"""
    demand(price, s::Student;p_neigh_parm::Int64=0)

Compute the total demand for classes based on the optimal individual bundles for a `student`.


## Arguments

Assume that N is the number of students, and C the number of classes that are available to choose from.

- `price` : a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.
- `student`: instance of type `Student`

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
function demand(price::Vector{Float64}, s::Student; p_neigh_parm::Int64=0)

	N = size(s.pref)[1]  # number of choices

	# Maximization problem
	m = Model(solver=GurobiSolver())

	@variable(m, x[1:N], Bin)

	# Objective: maximize utility
	@objective(m, Max, x'*s.pref*x)

	# Constraints:

	#Should not spend more than one's budget
	@constraint(m,  dot(price, x) <= s.budget )

	#Time Constraints
	@constraint(m, x'*s.time_const*x == 0 )

	#Mandatory courses
	@constraint(m, s.mand_cour_const'*x == 0 )

	#Tronc commun courses
	#TC courses
	@constraint(m, s.tc_cour_const'*x .- s.tc_requirement .>= 0)

	#TC program constraint
	@constraint(m, s.tc_cour_prog_const'*x .== 0 )

	#TC semester constraint
	@constraint(m, s.tc_cour_sem_const'*x .== 0 )

	#Formation commune courses
	#FC courses
	@constraint(m, s.fc_cour_const'*x .- s.fc_requirement .>= 0)

	#FC program constraint
	@constraint(m, s.fc_cour_prog_const'*x .== 0 )

	#FC semester constraint
	@constraint(m, s.fc_cour_sem_const'*x .== 0 )

	#Electives courses
	#TC courses
	@constraint(m, s.el_cour_const'*x .- s.el_requirement .>= 0)

	#TC program constraint
	@constraint(m, s.el_cour_prog_const'*x .== 0 )

	#TC semester constraint
	@constraint(m, s.el_cour_sem_const'*x .== 0 )

	#Neighboring prices constraint
	# require that course id p_neigh_parm must be chosen
	if p_neigh_parm ~= 0
		@constraint(m, x[p_neigh_parm] == 1)
	end

	# Solve problem using MIP solver
	status = solve(m)
	dem = getvalue(x)

	return dem
end

"""
	demand for all students
"""
function demand(price::Vector{Float64}, s::Array{Student})


	N = size(s[1].pref)[1]
	M = length(s)
    outdem = zeros(Int,M,N)

	for (i,stu) in enumerate(s)
		outdem[i,:] = demand(price,stu)
	end

  	return Dict(:ind_demands => out_dem,:course_demand => sum(out_dem,1),:total=>sum(out_dem) )
	# return Dict(:ind_demands => demand,:course_demand => sum(demand,1),:total=>sum(demand),:clearing_error=>err )

end

