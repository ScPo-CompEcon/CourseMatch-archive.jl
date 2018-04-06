#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Most of the objects will change.

#Preliminary inputs
    M = 5 #Number of courses offered
    k = 3 #Number of courses students take
    βmax = 20 #Maximum budget
    function d(p) #Demand function. To be replaced by solution to issue #4. For now a stupid downward sloping demand function.
        10-2*p
    end
    function N(p,M,k) #Generates set of neighbors. To be replaced by solution to issue #6. For now, this will just be a matrix of MxK with K copies of p
        y = Array{Float64}(M,k)
        [y[:,i] = p for i in 1:k]
        return y
    end
    function α(x) #clearing error function. To be replaced with solution to issue 1
        sum(x)
    end
    #t is overall time - performance

#Code to fill out

#QUESTION line1: I think besterror is just supposed to be an empty array.
besterror = Array{Float64}[]
#repeat from l.2 to 35. This is a do until runtime > t.
    p = [1,2,3,0,0] #Initial guess for p. Will be replaced also
    searcherror =  α(d(p)) #function from issue #1
    τ = Array{Float64}[]   #Empty. Will be filled by rejected solutions.
    c = 0
    # while loop from l.7 to 34
    while c < 5
        DoubleN = α(N(p),1) #Function that evaluates clearing error of neighbors and sorting in descending order. Another issue I'm not sure is in our list
        foundnextstep = false
        # repeat from l. 10 to 16
        while foundnextstep == false | isempty(DoubleN) == true
            ptild = DoubleN[:,2:end] #removes first row
            d = d(ptild)
            # if from l.13 to 15
            if #d is NOT in tau. We may actually need to create a function to do this.
                foundnextstep == true
            end
        # if from line 17 to 33
            # if from l.23 to 28
            # if from l.29 to 32
    end #end of while loop line 34
