#Inputs just to test loops
    M = 5 #Number of courses
    k = 3
    βmax = 20 #Maximum budget
    function d(p) #Demand function. To be replaced by solution to issue #4
        10-2*p
    end
    function N(p,M,k) #Generates set of neighbors. Issue 6
        #For now, this will just be a matrix of Mxk with K copies of p
        y = Array{Float64}(M,k)
        [y[:,i] = p for i in 1:k]
        return y
    end
    #t is overall time - performance
    
#Testing that it works ok for now
    p = [1,2,3,0,0] #initial guess
    ϕϕ = N(p,M,k)

#Code to fill out

# repeat from l.2 to 35
    τ =    #empty
    c=0
    # while loop from l.7 to 34
        # repeat from l. 10 to 16
            # if from l.13 to 15
        # if from line 17 to 33
            # if from l.23 to 28
            # if from l.29 to 32
