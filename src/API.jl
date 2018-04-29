"""
    timecons(programs, data)

Compute a sparse matrix indicating schedule conflicts between courses in a specified program.

# Arguments

- `programs` : a column vector of the programs names. Those names should be consistent with the one
specified in the data.
- `data` : a dataframe containing the names of the program, list of courses in those programs and
the time slot at which those courses take place.


    student(data, dictp)

Construct "Student" from the data.

# Arguments

- `data` : a dataframe containing students ID, the program and year they are enrolled in.
- `dictp` : a dictionary that contains the output from the `timecons` function


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


julia> programs = ["MIE", "Law", "Socio"]

3-element Array{String,1}:
 "MIE"
 "Law"
 "Socio"

julia> ptable = CSV.read("/Users/julielenoir/.julia/v0.6/CourseMatch/docs/Programs.csv" ; delim = ";")
42×3 DataFrames.DataFrame
│ Row │ program │ course │ slot │
├─────┼─────────┼────────┼──────┤
│ 1   │ MIE     │ FC1    │ L1   │
│ 2   │ MIE     │ FC2    │ L1   │
│ 3   │ MIE     │ FC3    │ M1   │
│ 4   │ MIE     │ TC11   │ L2   │
│ 5   │ MIE     │ TC12   │ M2   │
│ 6   │ MIE     │ TC13   │ M2   │
│ 7   │ MIE     │ TC21   │ M3   │
│ 8   │ MIE     │ TC22   │ M4   │
⋮
│ 34  │ Socio   │ TC13   │ M2   │
│ 35  │ Socio   │ TC21   │ M3   │
│ 36  │ Socio   │ TC22   │ M4   │
│ 37  │ Socio   │ TC23   │ M5   │
│ 38  │ Socio   │ OP11   │ J1   │
│ 39  │ Socio   │ OP12   │ L4   │
│ 40  │ Socio   │ OP13   │ J1   │
│ 41  │ Socio   │ OP21   │ V2   │
│ 42  │ Socio   │ OP22   │ J3   │

julia> dictprog = timecons(programs, ptable)
Dict{Any,Any} with 3 entries:
  "Law"   => …
  "MIE"   => …
  "Socio" => …

julia> stable = CSV.read("/Users/julielenoir/.julia/v0.6/CourseMatch/docs/Students.csv" ; delim = ";")
120×3 DataFrames.DataFrame
│ Row │ ID  │ Program │ Year │
├─────┼─────┼─────────┼──────┤
│ 1   │ 1   │ MIE     │ 1    │
│ 2   │ 2   │ MIE     │ 1    │
│ 3   │ 3   │ MIE     │ 1    │
│ 4   │ 4   │ MIE     │ 1    │
│ 5   │ 5   │ MIE     │ 1    │
│ 6   │ 6   │ MIE     │ 1    │
│ 7   │ 7   │ MIE     │ 1    │
│ 8   │ 8   │ MIE     │ 1    │
⋮
│ 112 │ 112 │ Socio   │ 2    │
│ 113 │ 113 │ Socio   │ 2    │
│ 114 │ 114 │ Socio   │ 2    │
│ 115 │ 115 │ Socio   │ 2    │
│ 116 │ 116 │ Socio   │ 2    │
│ 117 │ 117 │ Socio   │ 2    │
│ 118 │ 118 │ Socio   │ 2    │
│ 119 │ 119 │ Socio   │ 2    │
│ 120 │ 120 │ Socio   │ 2    │

julia> dictstud = student(stable, dictprog)
Dict{Any,Any} with 120 entries:
  "32"  => Student("MIE", 2, …
  "29"  => Student("MIE", 2, …
  "1"   => Student("MIE", 1, …
  "54"  => Student("Law", 1, …
  "78"  => Student("Law", 2, …
  "81"  => Student("Socio", 1, …
  "101" => Student("Socio", 2, …
  "2"   => Student("MIE", 1, …
  "105" => Student("Socio", 2, …
  "109" => Student("Socio", 2, …
  "74"  => Student("Law", 2, …
  "41"  => Student("Law", 1, …
  "65"  => Student("Law", 2, …
  "51"  => Student("Law", 1, …
  "53"  => Student("Law", 1, …
  "106" => Student("Socio", 2, …
  "119" => Student("Socio", 2, …
  "27"  => Student("MIE", 2, …
  "75"  => Student("Law", 2, …
  ⋮     => ⋮


"""

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
