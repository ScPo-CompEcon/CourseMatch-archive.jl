#= Demand function =#


#= Assume that N is the number of students, and C the number of classes that are available to choose from.

The argument to the *demand* function defined above should be such that :
	-> *price* is a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.

	-> *pref* is an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences. Each of the matrices contained in that array should be a squared matrix of dimension C.

	-> *budget* is a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.

	-> *capacity* is a column vector of dimension N x 1, which n-th element is the number of classes student n has to attend.

	-> *time_const* is an sparse array C x C that flags with 1 if the ith element HAS a clash with jth element. 0 otherwise.

	-> *mand__cour_const* is a vector C x 1. the i-th element is 1 if the course must be taken, 0 otherwise

	-> *prog_cour_const* is a vector C x 1. the i-th element is 1 if the course is NOT in the students's program. 0 otherwise.

	-> *sem_cour_const* is a vector C x 1. the i-th element is 1 if the course is NOT the students's semester

	-> *elec_cour_const* is a vector C x 1. the i-th element is 1 if the course is elective for the students

	-> *num_elec_cour* is the number of elective courses that the student is required to take

	=#

function demand(price, pref, budget, capacity, time_const, mand_const, prog_cour_const, sem_cour_const, elec_cour_const, num_elec_cour)

	dem = []

	N = size(pref)[1]

	let
		# Maximization problem
		m = Model(solver=GurobiSolver())

		@variable(m, x[1:N], Bin)

		# Objective: maximize utility
		@objective(m, Max, x'*pref*x)

		# Constraints:

		#Should have exactly 3 classes
		@constraint(m, sum(x) == capacity)

		#Should not spend more than one's budget
		@constraint(m,  dot(price, x) <= budget )

		#Time Constraints
		@constraint(m, x'*time_const*x == 0 )

		#Mandatory courses
		@constraint(m, mand_cour_const'*x == 0 )

		#Elective courses
		@constraint(m, elec_cour_const'*x - num_elec_cour >= 0)

		#Program courses
		@constraint(m, prog_cour_const'*x == 0 )

		#Program courses
		@constraint(m, sem_cour_const'*x == 0 )

		# Solve problem using MIP solver
		status = solve(m)
		dem = getvalue(x)
		return dem

	end

end


######

M = 20

for i in 1:M

	# Individual preferences are generated as an array of sparse diagonal matrices
	Ind_pref = sparse(collect(1:10), collect(1:10), rand(0:100, 10))

	# Individual budget
	ind_budget = rand(150:200)

	# Price vector
	price = rand(Float32, 10)

	# Capacity vector
	cap = rand(3:5)

	#Schedule collisions
	time_const = zeros(10,10)

	#Mandatory courses
	mand_cour_const = rand(0:1,10)

	#Program courses
	prog_cour_const = 1 - mand_const

	#Semester courses
	sem_cour_const = prog_cour_const

	#Elective courses
	elec_cour_const = ones(10,1)

	#Number of elective courses
	num_elec_cour = 1

	#Demand computation
	dem = demand(price, Ind_pref, ind_budget, cap, time_const, mand_const, prog_cour_const, sem_cour_const, elec_cour_const, num_elec_cour)

	mkt_demand = []
	push!(mkt_demand, dem)
	return mkt_demand
end

mkt_demand = Dict("ind_demands" => ans, "total_demand" => sum(ans) )



######
