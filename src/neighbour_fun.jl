

"""
    neighb_fun(price::Vector, demand, clear_error, pref, budget, capacity, ind_max::Int=40)

Return K neighbouring price vectors of the current vector p. The set is
the union of step search along the gradient of errors z and individual
course price adjustments.

# Parameters
- ind_max = the maxmimum number of individual price adjustments
"""
function neighb_fun(price::Vector, demand, clear_error, pref, budget, capacity, ind_max::Int=40)

    #gradient neighbours
    grad_neighb = grad_descent(price, clear_error)

    #individually adjusted neighbour prices
    if countnz(clear_error) <= ind_max
        indiv_neighb = [indiv_adjust(k, price, demand, clear_error, pref, budget, capacity) for k in 1:length(clear_error) if clear_error[k] != 0]
    else
        index  = sample(find(clear_error), ind_max, replace=false) # pick 40 random courses to adjust
        indiv_neighb = [indiv_adjust(k, price, demand, clear_error, pref, budget, capacity) for k in index]
    end

    return neighbour_vect = [grad_neighb ; indiv_neighb]
end

####### Gradient neighbours  #####

"Return the set of neighbours of price vector p found at different magnitudes
along the gradient of error. Increase the price of the most oversubscribed
course by magnitude, other course prices adjust relatively ."
function grad_descent(price::Vector, clear_error::Vector, steps=[10, 5, 1, 0.5, 0.1])
    relat_error = clear_error/maximum(clear_error) #relative clearing error
    grad_neighb = [max(price + (step * relat_error), 0) for step in steps] #price adjusted proportionaly to over/undersub, truncated at zero
    return grad_neighb
end


########## Individual adjustment ##########

"""
Adjust the price of course m to reduce demand by 1 if the course is oversubscribed
or drop the price to zero if the course is undersubscribed.
"""
function indiv_adjust(k::Int, price::Vector, demand, clear_error, pref, budget, capacity)
    adj_price = copy(price)

    if clear_error[k] < 0
        adj_price[k] = 0 # if course is undersubscribed, p = 0
    elseif clear_error[k] > 0
        adj_price[k] = decrease_demand(k, price, demand, clear_error, pref, budget, capacity)
    end

    return adj_price
end


"""
Return the adjusted price of course m such that its demand decreases by
exactly one.
"""
function decrease_demand(k::Int, price::Vector, demand, clear_error, pref, budget, capacity)
    S = length(pref) #number of students
    N = length(price) #number of courses
    min_increase = []

    for i in 1:S
        if dem["ind_demands"][i][k] == 1 #For all agents i demanding course k
        # 1) Find agent i's most prefered bundle not including x_m
            m1 = Model(solver=GurobiSolver())
            @variable(m1, x[1:N], Bin)
            @objective(m1, Max, x'*pref[i]*x) #max preferences
            @constraint(m1, sum(x) == capacity[i]) # course constraint
            @constraint(m1,  dot(price, x) <= budget[i]) # budget constraint
            @constraint(m1, x[k] == 0) # in set of bundles without course k
            status = solve(m1)
            o = getobjectivevalue(m1) # utility of most prefered bundle not including k

        # 2) Solve for minimum cost bundle in set of feasible solution with objective value greater than o
            m2 = Model(solver=GurobiSolver())
            @variable(m2, x[1:N], Bin)
            @objective(m2, Min, dot(price,x))
            @constraint(m2, x'*pref[i]*x >= o ) #bundles prefered to o
            @constraint(m2, sum(x) == capacity[i])
            @constraint(m2, x[k] == 1) #sechdule inclue course k
            status_2 = solve(m2)
            pi_opt = getobjectivevalue(m2) #cost of cheapest bundle including k

        # 3)Price increase for indiv i to drop course k
            if isnan(pi_opt) == false #drop infeasible results
                push!(min_increase, budget[i] - pi_opt + 1) #eps to be scaled to prices
            end
        end
    end
    return price[k] + minimum(min_increase)
end





