#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Most of the objects will change.
#Ongoing issues
    #1 - Sort Ndouble in descending order
    #2 - The last neighbord won't be tested the way the algorithm is designed right now
    #Not returning besterror


include("PseudoDemand.jl")
include("PseudoClearingError.jl")
include("PseudoNeighbor.jl")
include("loops.jl")


#Preliminary inputs
M = 5 #Number of courses offered
k = 3 #Number of courses students take
βmax = 20 #Maximum budget
t = 0.005

besterror = 100
#Defining variables for future
p = Array[]
ptild = Array[]
pstar = Array[]
searcherror = Array[]
DoubleN = Array[]
foundnextstep = Array[]
dem = zeros(M)
currenterror = Array[]
τ = Array[]  #Empty. Will be filled by rejected solutions.
# p = Array[[1,2,3,0,0]]
# #τ = d(p)
# push!(τ,d(p))
# p = Array[[0,0,0,0,0]]
# push!(τ,d(p))
# p = Array[[1,1,1,1,1]]
# push!(τ,d(p))
Np = Array[[0,0,0,0,0], [1,1,1,1,1], [1,2,3,0,0]]

function coursematch()
    starttime = Dates.Time(now())
    while (Dates.Time(now()) - starttime).value < t *1000000000
    #repeat from l.2 to 35. This is a do until runtime > t.
        global p = Array[[0,0,0,0,0]] #Initial guess for p. Will be replaced also
        global searcherror =  α.(d(p)) ##= 50 function from issue #1
        global c = 0
        # while loop from l.7 to 34
        while c < 5
            global DoubleN = Np
            #DoubleN = N(p) #Don't forget this needs to be sorted by clearing error (Issue #6)
            global foundnextstep = false
            # repeat from l. 10 to 16
            global dem = zeros(M)
            while foundnextstep == false | isempty(DoubleN) == false
                findingnextstep()
            end
            # if from line 17 to 33
            if isempty(DoubleN) == true
                global c = 5
            end
            if foundnextstep == true
                newsetup()
                global currenterror =  α.(dem)
                replacesearcherror()
                replacebesterror()
            end
        end
    end
    println(pstar)
end

coursematch()
