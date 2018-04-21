function N(p) #Generates set of neighbors. To be replaced by solution to issue #6. For now, this will just be a matrix of MxK with K copies of p
      y = Array[]
      for i in 1:3
          push!(y,p)
      end
      return y
  end
