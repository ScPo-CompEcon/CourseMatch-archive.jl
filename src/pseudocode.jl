#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Some of these objects can change.

include("PseudoDemand.jl")
include("PseudoClearingError.jl")
include("PseudoNeighbor.jl")
include("loops.jl")

#Defining variables for future
p = Array[] #searchstart
ptild = Array[] #new search price
pstar = Array[] #price that gives best error
searcherror = Array[] #best error in a searchstart
DoubleN = Array[] #neighbors of the search
foundnextstep = Array[] #boolean. true if a new search price has been found (one that does not generate the same demand as one that is in the tabu list)
dem = zeros(M) #the demand for courses at search price
currenterror = Array[] #error in the current search.
τ = Array[]  #Tabu list will be filled by rejected solutions.

#Preliminary inputs
M = 5 #Number of courses offered
k = 3 #Number of courses students take
βmax = 20 #Maximum budget
t = 0.005 #time in seconds
besterror = 100 #for now
Np = Array[[0,0,0,0,0], [1,1,1,1,1], [1,2,3,0,0]] #test neighbors

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
