    # Findingnextstep does the following : 1. It isolates the first neighbor (N1) of the neighbor list, removes N1 from neighbor list (such that N becomes N-1), checks the demand of N1, and checks if that demand is in the tabu list.
    function findingnextstep()
        global ptild = Array[DoubleN[1]]
        global DoubleN = DoubleN[2:end]
        global dem = d(ptild)
        #if from l.13 to 15
        checktabu()
    end

    #checktabu verifies if we've already checked a price vector that yields D(N1) demand for courses. If we have not, then we've found the price vector to check.
    function checktabu() #if from l.13 to 15
        if (dem in τ) == false #If dem is not in the tabu list
            global foundnextstep = true
            println(foundnextstep)
        else #Marie, remember to remove this eventually. It's useful to check that the code is making it to this step.
            println("No next step")
        end
    end

    #newsetup generates a new search using the price vector N1 if it was not in the tabu list. This also involes adding d(N1) to the tabu list.
    function newsetup()
        global p = ptild
        println(p)
        push!(τ,dem)
        #global currenterror = α.(dem)
    end

    #replacesearcherror will check is the current error is less than the best error in the search start (searcherror). If it is, then currenterror becomes the new searcherror. Since we've improved on our searcherror, the step counter starts again. If we haven't imroved on our search error, the step counter increases by 1.
    function replacesearcherror()
        if currenterror[1] < searcherror[1]
            global searcherror = currenterror
            println("New searcherror = $searcherror")
            global c = 0
            println(c)
        else
            global c = c + 1
            println("No new searcherror")
            println(c)
        end
    end

    #replacebesterror will check that the currenterror is less than the best error that from ALL search starts. If it is, then that currenterror becomes the best error and the associated price vector is the new best price. 
    function replacebesterror()
        if currenterror[1] < besterror[1]
            global besterror = currenterror
            println("New besterror is $besterror")
            global pstar = p
        end
    end
