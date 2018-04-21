#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Most of the objects will change.
#Ongoing issues
    #1 - Sort Ndouble in descending order
    #2 - The last neighbord won't be tested the way the algorithm is designed right now
    #Not returning besterror


include("PseudoDemand.jl")
include("PseudoClearingError.jl")
include("PseudoNeighbor.jl")
include("while2.jl")

#Preliminary inputs
M = 5 #Number of courses offered
k = 3 #Number of courses students take
βmax = 20 #Maximum budget
t = 1
starttime = Dates.Time(now())
besterror = 10
#Defining variables for future
p = Array[]
ptild = Array[]
pstar = Array[]
searcherror = Array[]
DoubleN = Array[]
foundnextstep = Array[]
dem = zeros(M)
currenterror = Array[]
#τ = Array[]  #Empty. Will be filled by rejected solutions.
τ = Array[d([1,2,3,0,0])]
Np = [[1,2,3,0,0], [0,0,0,0,0], [1,1,1,1,1]]
c = 0
#while (Dates.Time(now()) - starttime).value < t *1000000000
#repeat from l.2 to 35. This is a do until runtime > t.
    global p = Array[[1,2,3,0,0]] #Initial guess for p. Will be replaced also
    global searcherror =  α(d(p)) #function from issue #1
    global c = 0
    # while loop from l.7 to 34
    while c < 2
        global DoubleN = Np
        #DoubleN = N(p) #Don't forget this needs to be sorted by clearing error (Issue #6)
        global foundnextstep = false
        # repeat from l. 10 to 16
        dem = zeros(M)
        global c = c+1
        while foundnextstep == false | isempty(DoubleN) == false
            while2()
        end
    #end
end

T = Array[]
T2 = Array[[1,2]]
push!(T, T2)
T3 = Array[[3,4]]
push!(T, T3)
T4 = Array[[3,4]]


        while foundnextstep == false | isempty(DoubleN) == true
            global ptild = DoubleN[1]
            global foundnextstep = true
        end
    end
end


            global DoubleN = DoubleN[2:end]
            dem[:] = d(ptild)
            # if from l.13 to 15
            if !(dem in τ)
                global foundnextstep == true
            end
        end
        # if from line 17 to 33
        if isempty(DoubleN) == true #This means that all the d(p) were in our Tabu list and we need to restart the loop
            global c = 5   #This will end the while and generate a new start
        else
            global p = ptild
            push!(τ,dem)
            if p == [0,0,0,0,0]
                global currenterror = -1000000

            else
            global currenterror = α(dem)
            # if from l.23 to 28
            end
            if currenterror < searcherror
                global searcherror = currenterror
                global c = 0
            else
                global c = c + 1
            end
            # if from l.29 to 32
            if currenterror < besterror
                global besterror = currenterror
                global pstar = p
            end
        end
    end
    print(pstar)
end
#done
