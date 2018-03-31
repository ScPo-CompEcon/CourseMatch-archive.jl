module CourseMatch

	VERSION = VersionNumber(0,0,0)
	using JuMP, Cbc


	function best_bundle(;m=10,b=2)
		srand(1)
		# m = courses available
		k = 5 # courses to take
		price = collect(linspace(0.1,1,m))
		prefs = collect(linspace(0.1,1,m))

		println("price = $price")
		println("prefs = $prefs")

		model = Model(solver=CbcSolver())
		@variable(model, x[1:m] >= 0, Bin)  

		# objective: sum of preferences
		@objective(model, Max, dot(prefs,x) )

		# constraint: cost is less than budget
		@constraint(model, dot(price,x) <= b )

		# can only choose k courses out of all m
		@constraint(model, sum(x) <= k )

		status =solve(model)
		println("Objective is: ", getobjectivevalue(model))
		println("Solution is:")
		println("find(x) = $(find(getvalue(x)))")
		println("total cost = $(dot(price,getvalue(x)))")


	end

end # module
