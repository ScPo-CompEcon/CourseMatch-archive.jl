### This proposes a way to get data on Students in a proper way

# First we need to define for each program the classes that are available, and the schedules constraints

mutable struct Program
    program :: String
    courses :: Array{Tuple{String, String}}
    schedule :: Matrix
end

programs = ["MIE", "Law", "Socio"]

testp = Program("MIE", [("FC1", "L1"), ("FC2", "L2")], [0 0; 0 0])
testq = Program("Law", [("FC1", "L1"), ("FC2", "L2")], [0 0; 0 1])
testh = Program("Socio", [("FC1", "L1"), ("FC2", "L2"), ("FC3", "L1")], [1 0; 0 1])
T = Dict("MIE" => testp, "Law" => testq)

mutable struct Student
    program :: String
    year :: Int
    time_constr :: Matrix
    prog_constr :: Matrix
    allocation :: Vector{Int}
end


student = CSV.read("/Users/julielenoir/.julia/v0.6/CourseMatch/docs/Students.csv" ; delim = ";")

function student(datas, dictp)
    d = dict()

    for i in 1:nrow(datas)
        s = datas[:ID][i]
        p = datas[:program][i]
        d["$s"] = Student(datas[:Year][i],
                    timecons,
                    progcons,
                    fill(0, length(T[p].courses))
                    )
    end
    return d
end
