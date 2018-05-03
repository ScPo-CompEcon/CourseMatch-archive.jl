module CourseMatch

	VERSION = VersionNumber(0,0,1)

using JuMP, Cbc, Gurobi, CSV, DataFrames


# Demand function
include("demand.jl")
include("student.jl")




end # module
