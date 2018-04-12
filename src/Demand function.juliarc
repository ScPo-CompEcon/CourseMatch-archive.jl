using JuMP, Gurobi

m = Model(solver = GurobiSolver())

@variable(m, x[1:3], Bin)

utility = [80 10 -50; 10 90 0; -50 0 60]
price = [20, 30, 15]
budget = 50

@objective(m, Max, x'*utility*x)

#profit = [10 20 30]

@constraint(m, price'*x <= budget)

status = solve(m)

for i in 1:3
    println("x[$i] = ", getvalue(x[i]))
end
