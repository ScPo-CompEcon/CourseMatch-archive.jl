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
function demand!(price::Vector{Float64}, s::Student; p_neigh_parm::Int64=0)

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
	@constraint(m, x'*s.C_time*x == 0 )

	#Mandatory courses
	@constraint(m, s.C_mandatory'*x == 0 )

	#Tronc commun courses
	#TC courses
	@constraint(m, s.C_TC_courses'*x .- s.req_TC .>= 0)

	#TC program constraint
	@constraint(m, s.C_TC_program'*x .== 0 )

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

	# store on the student
	if status == :Optimal 
		s.allocation = getvalue(x)
	else 
		warn("MIP problem not solved. status = $status")
	end
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




# - `price` : a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.
# - `Student.pref` : an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences. Each of the matrices contained in that array should be a squared matrix of dimension C.
# - `Student.budget` : a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.
# - `Student.time_const` : a sparse array C x C that flags with 1 if the ith element HAS a clash with jth element. 0 otherwise.
# - `Student.mand_cour_const` : a vector C x 1. the i-th element is 1 if the course must be taken, 0 otherwise
# - `Student.tc_cour_prog_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the TC of the students's program. 0 otherwise.
# - `Student.tc_cour_sem_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the TC of the students's semester
# - `Student.tc_cour_const` : a vector C x 1. the i-th element is 1 if the course is part of the TC for the student
# - `Student.tc_requirement` : number of TC courses that the student is required to take
# - `Student.fc_cour_prog_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the FC of the students's program. 0 otherwise.
# - `Student.fc_cour_sem_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the FC of the students's semester
# - `Student.fc_cour_const` : a vector C x 1. the i-th element is 1 if the course is part of the FC for the student
# - `Student.fc_requirement` : number of FC courses that the student is required to take
# - `Student.el_cour_prog_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the electives of the students's program. 0 otherwise.
# - `Student.el_cour_sem_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the electives of the students's semester
# - `Student.el_cour_const` : a vector C x 1. the i-th element is 1 if the course is part of the electives choice for the student
# - `Student.el_requirement` : number of electives courses that the student is required to take
# - `p_neigh_parm` : course that needs to be dropped in order to compute neigboring prices
# ## Example
# * 20 individuals
# * 15 classes to choose from
# * Random classes to attend between 4 and 6
# * Random number of mandatory classes to attend with an average of 2 per student
# * Two random time collisions per student in non?mandatory courses
# * Two random courses that are not allowed to be taken by the program of the student
# * Two random courses that are not allowed to be taken by the semester of the student
# * Two random courses are electives for each student, they are required to take 1
# * NO CROSS PREFERENCES, i.e. Individual preferences are generated as an array of sparse diagonal matrices
# ```
# num_stud = 20
# num_cour = 15
# mkt_demand = []
# for i in 1:num_stud
# 	# Individual preferences are generated as an array of sparse diagonal matrices
# 	Ind_pref = sparse(collect(1:num_cour), collect(1:num_cour), rand(-100:100, num_cour))
# 	# Individual budget
# 	ind_budget = 150+rand()
# 	# Price vector
# 	price = 100*rand(Float32, size(Ind_pref,1))
# 	# Capacity vector
# 	cap = rand(4:6)
# 	#Mandatory courses
# 	mand_cour_const = rand(Binomial(1,0.13), size(Ind_pref,1))
# 	#Flag non Mandatory courses
# 	non_mand = findn(mand_cour_const .== 0)
# 	#Schedule collisions
# 	time_const = zeros(size(Ind_pref,1), size(Ind_pref,1))
# 	time_const[non_mand[1],non_mand[2]] = time_const[non_mand[2],non_mand[1]] = 1
# 	time_const[non_mand[3],non_mand[4]] = time_const[non_mand[4],non_mand[3]] = 1
# 	#Program courses
# 	prog_cour_const = zeros(size(Ind_pref,1),1)
# 	prog_cour_const[non_mand[5]] = 1
# 	prog_cour_const[non_mand[6]] = 1
# 	#Semester courses
# 	sem_cour_const = zeros(size(Ind_pref,1),1)
# 	sem_cour_const[non_mand[7]] = 1
# 	sem_cour_const[non_mand[8]] = 1
# 	#Elective courses
# 	elec_cour_const = zeros(size(Ind_pref,1),1)
# 	elec_cour_const[non_mand[9]] = 1
# 	elec_cour_const[non_mand[10]] = 1
# 	#Number of elective courses
# 	num_elec_cour = 1
# 	#Demand computation
# 	dem = demand(price, Ind_pref, ind_budget, cap, time_const, mand_cour_const, prog_cour_const, sem_cour_const, elec_cour_const, num_elec_cour)
# 	push!(mkt_demand, dem)
# 	return mkt_demand