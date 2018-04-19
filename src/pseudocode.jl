#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Most of the objects will change.
#Ongoing issues
    #1 - Sort Ndouble in descending order
    #2 - The last neighbord won't be tested the way the algorithm is designed right now
    #Not returning besterror

#Preliminary inputs
    M = 5 #Number of courses offered
    k = 3 #Number of courses students take
    βmax = 20 #Maximum budget
    function d(p) #Demand function. To be replaced by solution to issue #4. For now a stupid downward sloping demand function.
        10-2*p
    end
    function N(p) #Generates set of neighbors. To be replaced by solution to issue #6. For now, this will just be a matrix of MxK with K copies of p
        y = Array[]
        for i in 1:3
            push!(y,p)
        end
        return y
    end

    function α(x) #clearing error function. To be replaced with solution to issue 1
        sum(x)
    end

    #
    function while2()
        global ptild = DoubleN[1]
        global foundnextstep = true
        global DoubleN = DoubleN[2:end]
        global dem = d(ptild)
        # if from l.13 to 15
        if !(dem in τ)
            foundnextstep == true
        end
    end



t = 1
starttime = Dates.Time(now())
besterror = 10
#Defining variables
p = Array[]
ptild = Array[]
pstar = Array[]
searcherror = Array[]
DoubleN = Array[]
foundnextstep = Array[]
dem = zeros(M)
currenterror = Array[]
τ = Array[]  #Empty. Will be filled by rejected solutions.
Np = [[1,2,3,0,0] [0,0,0,0,0] [1,1,1,1,1]]
c = 0
h =0
#while (Dates.Time(now()) - starttime).value < t *1000000000
#repeat from l.2 to 35. This is a do until runtime > t.
    global p = [1,2,3,0,0] #Initial guess for p. Will be replaced also
    global searcherror =  α(d(p)) #function from issue #1
    global c = 0
    # while loop from l.7 to 34
    while c < 5
        global DoubleN = Np
        #DoubleN = N(p) #Don't forget this needs to be sorted by clearing error (Issue #6)
        global foundnextstep = false
        # repeat from l. 10 to 16
        dem = zeros(M)
        global c = c+1
        h = 0
        while h < 5
            while2()
        end
    end
end


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
