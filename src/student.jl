"""
    timecons(data)

Compute a sparse matrix indicating schedule conflicts between courses in a specified program.

# Arguments

- `data` : a dataframe containing the names of the program, list of courses in those programs and
the time slot at which those courses take place.

# Example


The CSV files used for this example are stored in the "docs" directory of the repo.
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


"""
function timecons(data)

    d = Dict()
    programs = unique(data[:Program])

    for p in programs, s in 1:2
        df = data[findin(data[:Program],[p]),:]
        df1 = df[findin(df[:ClassS], [s, 12]),:]
        P = fill(0, nrow(df1), nrow(df1))
        for i in 1:(length(df1)-1)
            if df1[:slot][i] == df1[:slot][i+1]
                P[i, i+1] = 1
            end
        end
        d["$p$s"] = sparse(P)
    end
    return d
end

"""
# constraints 

* `time`: a sparse matrix C x C that flags with 1 if the ith element HAS a clash with jth element. 0 otherwise.
* `mandatory`: a vector C x 1. the i-th element is 1 if the course must be taken, 0 otherwise
* `notTCprogram`: a vector C x 1. the i-th element is 1 if the course is NOT in the TC of the students's program
* `notTCsemester`: a vector C x 1. the i-th element is 1 if the course is NOT in the TC of the students's semester
* `isTC`: a vector C x 1. the i-th element is 1 if the course IS in the TC of the students
* `notFCprogram`: a vector C x 1. the i-th element is 1 if the course is NOT in the FC of the students's program
* `notFCsemester`: a vector C x 1. the i-th element is 1 if the course is NOT in the FC of the students's semester
* `isFC`: a vector C x 1. the i-th element is 1 if the course IS in the FC of the students
* `notELprogram`: a vector C x 1. the i-th element is 1 if the course is NOT in the EL (electives) of the students's program
* `notELsemester`: a vector C x 1. the i-th element is 1 if the course is NOT in the EL of the students's semester
* `isEL`: a vector C x 1. the i-th element is 1 if the course IS in the EL of the students

"""
struct Constraints
    clash         :: SparseMatrixCSC{Int,Int}
    mandatory     :: Vector{Bool}
    notTCprogram  :: Vector{Bool}
    notTCsemester :: Vector{Bool}
    isTC          :: Vector{Bool}
    notFCprogram  :: Vector{Bool}
    notFCsemester :: Vector{Bool}
    isFC          :: Vector{Bool}
    notELprogram  :: Vector{Bool}
    notELsemester :: Vector{Bool}
    isEL          :: Vector{Bool}
end

"random constraints"
function rand_constraints(N)
    if N<2
        error("N must be > 2")
    end
    clash = sparse(collect(1:2),collect(1:2),ones(Int,2),N,N)
    mandatory = rand([true false],N)
    notTCprogram = rand([true false false false false false],N)
    notTCsemester = rand([true false false false false false],N)
    isTC = rand([true false],N)
    notFCprogram = rand([true false false false false false],N)
    notFCsemester = rand([true false false false false false],N)
    isFC = rand([true false],N)
    notELprogram = rand([true false false false false false],N)
    notELsemester = rand([true false false false false false],N)
    isEL = rand([true false],N)
    return Constraints(clash,mandatory,notTCprogram,notTCsemester,isTC,notFCprogram,notFCsemester,isFC,notELprogram,notELsemester,isEL)
end


"""
# Student

## Fields

- `price` : a column vector of dimension C x 1, which i-th element is the price that was assigned to class i.
- `preferences` : an array containing S elements, and such that its n-th element is the (sparse) matrix representing student n preferences. Each of the matrices contained in that array should be a squared matrix of dimension C.
- `budget` : a column vector of dimension N x 1, which n-th element is the budget that was allocated to the n-th student.
- `constraints`: an instance of a [`Constraints`](@ref)
- `req_TC` : number of TC courses that the student is required to take
- `req_FC` : number of FC courses that the student is required to take
- `req_EL` : number of EL courses that the student is required to take
"""
mutable struct Student
    preferences :: SparseMatrixCSC{Int64, Int64}
    program :: String
    year :: Int64
    constraints :: Constraints
    req_FC :: Int64
    req_TC :: Int64
    req_EL :: Int64
    budget :: Float64
    allocation :: Array{Int64,1}

    function Student(N=10;preferences=spzeros(N,N),
                     program="MIE",
                     year::Int=1,
                     constraints=Constraints(N),
                     req_FC::Int=1,
                     req_TC::Int=2,
                     req_EL::Int=1,
                     budget = rand()*100)
        new(
            preferences,
            program,
            year,
            constraints,
            req_FC,
            req_TC,
            req_EL,
            budget,
            zeros(N))
    end
end


"""
    read_students()

Construct `Student`s from artificial time sheet data.

# Example

julia> CourseMatch.read_students()
Dict{Int64,CourseMatch.Student} with 120 entries:
  68  => CourseMatch.Student("Law", 2, …
  2   => CourseMatch.Student("MIE", 1, …
  89  => CourseMatch.Student("Socio", 1, …
  11  => CourseMatch.Student("MIE", 1, …
  39  => CourseMatch.Student("MIE", 2, …
  46  => CourseMatch.Student("Law", 1, …
  85  => CourseMatch.Student("Socio", 1, …
  25  => CourseMatch.Student("MIE", 2, …
  55  => CourseMatch.Student("Law", 1, …
  42  => CourseMatch.Student("Law", 1, …
  29  => CourseMatch.Student("MIE", 2, …
  58  => CourseMatch.Student("Law", 1, …
  66  => CourseMatch.Student("Law", 2, …
  59  => CourseMatch.Student("Law", 1, …
  8   => CourseMatch.Student("MIE", 1, …
  ⋮   => ⋮
"""
function read_students()
	data = CSV.read(joinpath(dirname(@__FILE__),"..","docs","Students.csv") ; delim = ";")
	ptable = CSV.read(joinpath(dirname(@__FILE__),"..","docs","Programs.csv") ; delim = ";")
	dictp = timecons(ptable)
    d = Dict{Int,Student}()
    for i in 1:nrow(data)
        s = data[:ID][i]
        d[s] = Student(sparse(collect(1:10), collect(1:10), rand(0:100, 10)),
                    data[:ProgSem][i],
                    data[:ProgSem][i][end],
                    dictp[p],
                    #progcons,
                    1,
                    rand(1:2),
                    3,
                    150+rand(),
                    fill(0, size(dictp[p])[1])
                    )
    end
    return d
end
