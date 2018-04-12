#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Most of the objects will change.
#Ongoing issues
    #1 - Sort Ndouble in descending order

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
    starttime = Dates.Time(now())

while (Dates.Time(now()) - starttime).value < t *1000000000
besterror = Array{Float64}[]
#repeat from l.2 to 35. This is a do until runtime > t.
    p = [1,2,3,0,0] #Initial guess for p. Will be replaced also
    searcherror =  α(d(p)) #function from issue #1
    τ = Array()  #Empty. Will be filled by rejected solutions.
    c = 0
    # while loop from l.7 to 34
    while c < 5
        DoubleN = α(N(p),1) #Function that evaluates clearing error of neighbors and sorting in descending order. Another issue I'm not sure is in our list
        foundnextstep = false
        # repeat from l. 10 to 16
        while foundnextstep == false | isempty(DoubleN) == true
            ptild = DoubleN[:,1]
            DoubleN = DoubleN[:,2:end]
            d = d(ptild)
            # if from l.13 to 15
            if !(d in τ)
                foundnextstep == true
            end
        end
        # if from line 17 to 33
        if isempty(DoubleN) == true #This means that all the d(p) were in our Tabu list and we need to restart the loop
            c = 5   #This will end the while and generate a new start
        else
            p = ptild
            push!(τ,d)
            currenterror = α(d)
            # if from l.23 to 28
            if currenterror < searcherror
                searcherror = currenterror
                c = 0
            else
                c = c + 1
            end
            # if from l.29 to 32
            if currenterror < besterror
                besterror = currenterror
                pstar = p
            end
        end
    end
end
#done
