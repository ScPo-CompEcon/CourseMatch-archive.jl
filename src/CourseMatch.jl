module CourseMatch

	VERSION = VersionNumber(0,0,0)
	using JuMP, Gurobi


	function best_bundle(;k=3,m=10,b=2)
		srand(1)
		# m = courses available

		price = collect(linspace(0.1,1,m))
		prefs = collect(linspace(0.1,1,m))

		println("price = $price")
		println("prefs = $prefs")

		c=zeros(m,m)
		c[1,2] = 1
		c[1,8] = 1

		model = Model(solver=GurobiSolver())
		@variable(model, x[1:m] >= 0, Bin)  

		# objective: sum of preferences
		@objective(model, Max, dot(prefs,x) )

		# constraint: cost is less than budget
		@constraint(model, dot(price,x) <= b )

		# can only choose k courses out of all m
		@constraint(model, sum(x) <= k )

		# # cannot choose infeasible courses
		@constraint(model, vecdot(x'*c, x) == 0)
			 

		status =solve(model)
		println("Objective is: ", getobjectivevalue(model))
		println("Solution is:")
		println("find(x) = $(find(getvalue(x)))")
		println("total cost = $(dot(price,getvalue(x)))")


	end

end # module
