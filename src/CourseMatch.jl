module CourseMatch

	VERSION = VersionNumber(0,0,1)

using JuMP, Cbc, Gurobi, CSV, DataFrames


# includes
include("demand.jl")
include("student.jl")

# exports




end # module
