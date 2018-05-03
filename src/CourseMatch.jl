module CourseMatch

	VERSION = VersionNumber(0,0,0)

using JuMP, Cbc, Gurobi, CSV, DataFrames


#API : reading student data

# Demand function
include("Issue#4-demandfunc.jl")
include("API.jl")




end # module
