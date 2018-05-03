#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Some of these objects can change.

include("PseudoDemand.jl")
include("PseudoClearingError.jl")
include("PseudoNeighbor.jl")
include("loops.jl")

#Preliminary variables
#test neighbors

function coursematch(M, k, βmax, besterror, t, Np)
    ptild = Array{Int}(M) #new search price
    pstar = Array[] #price that gives best error
    searcherror = Array[] #best error in a searchstart
    DoubleN = Array[] #neighbors of the search
    foundnextstep = Array{Bool}(1) #boolean. true if a new search price has been found (one that does not generate the same demand as one that is in the tabu list)
    dem = zeros(M) #the demand for courses at search price
    currenterror = Array[] #error in the current search.
    τ = Array[]
    starttime = Dates.Time(now())
    while (Dates.Time(now()) - starttime).value < t *1000000000
    #repeat from l.2 to 35. This is a do until runtime > t.
        p = Array[[0,0,0,0,0]] #Initial guess for p. Will be replaced also
        searcherror =  α.(d(p)) ##= 50 function from issue #1
        c = 0
        # while loop from l.7 to 34
        while c < 5
            DoubleN = Np
            #DoubleN = N(p) #Don't forget this needs to be sorted by clearing error (Issue #6)
            foundnextstep[1] = false
            # repeat from l. 10 to 16
            findnextprices!(ptild,  DoubleN, dem, foundnextstep, τ)
            # if from line 17 to 18
            if isempty(DoubleN) == true
                c = 5
            end
            #l. 19 to 33
            if foundnextstep[1] == true
                push!(τ,copy(dem))
                p = copy(ptild)
                currenterror =  α(dem)
                c = resetcounter(currenterror, searcherror, c)
                searcherror = replacesearcherror(currenterror, searcherror)
                pstar = replacepstar(currenterror, besterror, p, pstar)
                besterror = replacebesterror(currenterror, besterror)
            end
        end
    end
    return pstar
end

M = 5 #Number of courses offered
k = 3 #Number of courses students take
βmax = 20 #Maximum budget
t = 0.005 #time in seconds
besterror = 100 #for now
Np = Array[[0,0,0,0,0], [1,1,1,1,1], [1,2,3,0,0]]
pstar = coursematch(M, k, βmax, besterror, t, Np)
