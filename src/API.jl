# API


# This proposes a way to get data on Students in a convenient way

# First we need to define for each program the classes that are available, and the schedules constraints

function timecons(programs, data)

    d = Dict()

    for p in programs
        df = data[findin(data[:program],[p]),:]
        P = fill(0, nrow(df), nrow(df))
        for i in 1:(length(df)-1)
            if df[:slot][i] == df[:slot][i+1]
                P[i, i+1] = 1
            end
        end
        d[p] = sparse(P)
    end
    return d
end


# Then we define a new type of variable called "Student"

mutable struct Student
    program :: String
    year :: Int64
    time_constr :: SparseMatrixCSC{Int64,Int64}
    #prog_constr :: Matrix
    allocation :: Array{Int64,1}
end


function student(data, dictp)
    d = Dict()

    for i in 1:nrow(data)
        s = data[:ID][i]
        p = data[:Program][i]
        d["$s"] = Student(p,
                    data[:Year][i],
                    dictp[p],
                    #progcons,
                    fill(0, size(dictp[p])[1])
                    )
    end
    return d
end


############## EXAMPLE ####################
#= The CSV files used for this example are stored in the "docs" directory of the repo.
We assume that there are 3 programs, Master in Economics ("MIE"), Law degree ("Law")
and Sociology degree ("Socio").

The Students.csv files contains the list of students and indicates the program they are
currently enrolled in and if they are in first or second year.

The Programs.csv files contains the detailed list of classes offer in a program. Different types
of classes are available in each program. The "FC" prefix stands for "Formation Commune". The "TC"
prefix stands for "Tronc Commun" and the "OP" prefix stands for "Optional class".
The first number in the name of the course indicates to which students the course is proposed. The
second number is the course ID.
For instance "TC11" is the first "Tronc Commun" offered to first year student, and "OP23" is the third
"Optional course" offeref to second year students.
I assumed that all formations communes were open to all students (which is the case in Sciences Po), which
justifies the use of only one number in the course ID. For instance "FC2" is the second "Formation Commune"
offered to all students.

The "slot" column indicates the day and slot number at which the course takes place. The days are indicated
by the letter and the time slot by the number. I assumed that there were 5 slots in a day.
Note that Sciences Po schedule is made such that no course slot overlaps another. All slots are independant.
For instance "L1" stands for the first slot on Monday, and "R5" for the fifth slot on Tuesday.

=#


programs = ["MIE", "Law", "Socio"]

ptable = CSV.read("/Users/julielenoir/.julia/v0.6/CourseMatch/docs/Programs.csv" ; delim = ";")

dictprog = timecons(programs, ptable)

#= I have designed the Programs.csv file such that only two classes overlap, that is FC1 and FC2 on one hand
and TC22 and TC23 on the other hand. =#

stable = CSV.read("/Users/julielenoir/.julia/v0.6/CourseMatch/docs/Students.csv" ; delim = ";")

dictstud = student(stable, dictprog)



##########################################
