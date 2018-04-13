
    """
        neighb_fun(p::Vector, z::Vector, <keyword arguments>)

    Return K neighbouring price vectors of the current vector p. The set is
    the union of step search along the gradient of errors z and individual
    course price adjustments.

    # Arguments
    - `s::Float64=1.0` : the step size of the gradient search
    - `S::Int=12` : the number of steps along gradient
    - `ind_max::Int` = the maxmimum number of individual price adjustments
    """
    function neighb_fun(p::Vector, z::Vector, s::Float64=1.0, S::Int=12, ind_max::Int=40)
        return neighbour_vect = [grad_neighb(p, z, s, S); indiv_adjust(p, z, ind_max)]
    end

    "Return the set of neighbours of price vector p found after performing S
    steps along the gradient vector."
    function grad_neighb(p::Vector,z::Vector,step_size::Float64, steps::Int)
        relat_error = z/maximum(z) #relative clearing error
        grad_neighb = [p + (step_size * s * relat_error) for s in 1:steps] #for each step price adjusted proportionaly to over/undersub.
        return grad_neighb
    end

    " Return a price vector with adjusted price for course m such that:
    If m is oversubscribed increase price to decrease error by 1, if m is
    undersubscribed drop course price to zero."
    function adjust_rule(m::Int, p::Vector, z::Vector)
        p_adj = copy(p) #make copy instead of pointer
        if z[m] < 0
            p_adj[m] = 0 # if course is undersubscribed, p = 0
        elseif z[m] > 0
            p_adj[m] += 1 # MISSING: if course oversub. reduce demand for m by 1
        end
        return p_adj
    end

    "Return the set I of individual-course adjusted price vectors, with an upper bound on I."
    # Set of individually adjusted price neighbours
    function indiv_adjust(p::Vector, z::Vector, ind_max::Int=40)
        if countnz(z) <= ind_max
            ind_adj_neighb = [adjust_rule(m, p, z) for m in 1:length(z) if z[m] != 0]
        else
            # MISSING - pick 40 random courses to adjust ("evenly and randomly assigned")
            ind_adj_neighb = [adjust_rule(m, p, z) for m in 1:length(z) if z[m] != 0]
        end
        return ind_adj_neighb
    end

    # TEST - most basic - M=4
    p = [15.09,5.211,4.37,4.0]
    z = [0,-5,10,8] #clearing error
    N = neighb_fun(p,z)
    # should return a K=12+3=15-element array of 4-element vectors:
    # - price of course 1 should not change
    # - price of course 2 should drop to 0 in indiv search
