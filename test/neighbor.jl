    ##### TEST - 20 individuals, 10 classes to choose from, exactly 3 classes to attend

    #setup
    ind_pref = []
    for i in 1:20
        push!(ind_pref, sparse(collect(1:10), collect(1:10), rand(0:100, 10)))
    end

    budget = rand(150:200, 20)
    capacity = fill(3, 20)
    price = rand(30:70, 10)
    max_spots = rand(5:7, 10)

    dem = demand(price, ind_pref, budget, capacity)
    clear_error = dem["total_demand"] - max_spots

    # Test functions
    #grad neighbour
    grad_descent(price, clear_error)
    # should return 5 element array (10 element vectors)

    # indiv neighbour
    #decrease_demand(k, price, dem, clear_error, ind_pref, budget, capacity)
    k = 2
    new_price = indiv_adjust(k, price, demand, clear_error, ind_pref, budget, capacity)
    dem2 = demand(new_price, ind_pref, budget, capacity)
    clear_error2 = dem2["total_demand"] - max_spots
    #should find either new_price k = 0 or new clear error drop by 1

    neighb_fun(price, demand, clear_error, ind_pref, budget, capacity)