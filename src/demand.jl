"""
    demand(price::Vector, Student::Student, p_neigh_parm::Int64=1)

Compute the total demand for classes based on the optimal individual bundles given preferences, budget and prices, and under constraints such as program, semester and time clashes using the `GurobiSolver()`.


## Arguments

Assume that N is the number of students, and C the number of classes that are available to choose from.

- `price` : a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.
- `Student.pref` : an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences. Each of the matrices contained in that array should be a squared matrix of dimension C.
- `Student.budget` : a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.
- `Student.capacity` : a column vector of dimension N x 1, which n-th element is the number of classes student n has to attend.
- `Student.time_const` : a sparse array C x C that flags with 1 if the ith element HAS a clash with jth element. 0 otherwise.
- `Student.mand_cour_const` : a vector C x 1. the i-th element is 1 if the course must be taken, 0 otherwise
- `Student.tc_cour_prog_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the TC of the students's program. 0 otherwise.
- `Student.tc_cour_sem_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the TC of the students's semester
- `Student.tc_cour_const` : a vector C x 1. the i-th element is 1 if the course is part of the TC for the student
- `Student.tc_requirement` : number of TC courses that the student is required to take
- `Student.fc_cour_prog_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the FC of the students's program. 0 otherwise.
- `Student.fc_cour_sem_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the FC of the students's semester
- `Student.fc_cour_const` : a vector C x 1. the i-th element is 1 if the course is part of the FC for the student
- `Student.fc_requirement` : number of FC courses that the student is required to take
- `Student.el_cour_prog_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the electives of the students's program. 0 otherwise.
- `Student.el_cour_sem_const` : a vector C x 1. the i-th element is 1 if the course is NOT in the electives of the students's semester
- `Student.el_cour_const` : a vector C x 1. the i-th element is 1 if the course is part of the electives choice for the student
- `Student.el_requirement` : number of electives courses that the student is required to take
- `p_neigh_parm` : course that needs to be dropped in order to compute neigboring prices

## Example

* 20 individuals
* 15 classes to choose from
* Random classes to attend between 4 and 6
* Random number of mandatory classes to attend with an average of 2 per student
* Two random time collisions per student in non?mandatory courses
* Two random courses that are not allowed to be taken by the program of the student
* Two random courses that are not allowed to be taken by the semester of the student
* Two random courses are electives for each student, they are required to take 1
* NO CROSS PREFERENCES, i.e. Individual preferences are generated as an array of sparse diagonal matrices

```
num_stud = 20
num_cour = 15
mkt_demand = []

for i in 1:num_stud

	# Individual preferences are generated as an array of sparse diagonal matrices
	Ind_pref = sparse(collect(1:num_cour), collect(1:num_cour), rand(-100:100, num_cour))

	# Individual budget
	ind_budget = 150+rand()

	# Price vector
	price = 100*rand(Float32, size(Ind_pref,1))

	# Capacity vector
	cap = rand(4:6)

	#Mandatory courses
	mand_cour_const = rand(Binomial(1,0.13), size(Ind_pref,1))

	#Flag non Mandatory courses
	non_mand = findn(mand_cour_const .== 0)

	#Schedule collisions
	time_const = zeros(size(Ind_pref,1), size(Ind_pref,1))
	time_const[non_mand[1],non_mand[2]] = time_const[non_mand[2],non_mand[1]] = 1
	time_const[non_mand[3],non_mand[4]] = time_const[non_mand[4],non_mand[3]] = 1

	#Program courses
	prog_cour_const = zeros(size(Ind_pref,1),1)
	prog_cour_const[non_mand[5]] = 1
	prog_cour_const[non_mand[6]] = 1

	#Semester courses
	sem_cour_const = zeros(size(Ind_pref,1),1)
	sem_cour_const[non_mand[7]] = 1
	sem_cour_const[non_mand[8]] = 1

	#Elective courses
	elec_cour_const = zeros(size(Ind_pref,1),1)
	elec_cour_const[non_mand[9]] = 1
	elec_cour_const[non_mand[10]] = 1

	#Number of elective courses
	num_elec_cour = 1

	#Demand computation
	dem = demand(price, Ind_pref, ind_budget, cap, time_const, mand_cour_const, prog_cour_const, sem_cour_const, elec_cour_const, num_elec_cour)

	push!(mkt_demand, dem)
	return mkt_demand
end

mkt_demand = Dict("ind_demands" => ans, "total_demand" => sum(ans) )

"""

#function demand(price::Vector, '''Student::Student''', pref::SparseMatrixCSC{Int64, Int64}, Student.budget::Int64, Student.capacity::Int64, time_const::SparseMatrixCSC{Int8, Int8}, mand_cour_const::Vector, prog_cour_const, sem_cour_const, elec_cour_const, num_elec_cour, p_neigh_parm::Int64)
function demand(price::Vector, Student::Student, p_neigh_parm::Int64=0)

	dem = []

	N = size(Student.pref)[1]

	let
		# Maximization problem
		m = Model(solver=GurobiSolver())

		@variable(m, x[1:N], Bin)

		# Objective: maximize utility
		@objective(m, Max, x'*Student.pref*x)

		# Constraints:

		#Should not spend more than one's budget
		@constraint(m,  dot(price, x) <= Student.budget )

		#Time Constraints
		@constraint(m, x'*Student.time_const*x == 0 )

		#Mandatory courses
		@constraint(m, Student.mand_cour_const'*x == 0 )

		#Tronc commun courses
			#TC courses
			@constraint(m, Student.tc_cour_const'*x .- Student.tc_requirement .>= 0)

			#TC program constraint
			@constraint(m, Student.tc_cour_prog_const'*x .== 0 )

			#TC semester constraint
			@constraint(m, Student.tc_cour_sem_const'*x .== 0 )

		#Formation commune courses
			#FC courses
			@constraint(m, Student.fc_cour_const'*x .- Student.fc_requirement .>= 0)

			#FC program constraint
			@constraint(m, Student.fc_cour_prog_const'*x .== 0 )

			#FC semester constraint
			@constraint(m, Student.fc_cour_sem_const'*x .== 0 )

		#Electives courses
			#TC courses
			@constraint(m, Student.el_cour_const'*x .- Student.el_requirement .>= 0)

			#TC program constraint
			@constraint(m, Student.el_cour_prog_const'*x .== 0 )

			#TC semester constraint
			@constraint(m, Student.el_cour_sem_const'*x .== 0 )

		#Neighboring prices constraint
		if p_neigh_parm ~= 0
			@constraint(m, x[p_neigh_parm] == 1)
		end

		# Solve problem using MIP solver
		status = solve(m)
		dem = getvalue(x)
		return dem

	end

end
