#Clearing Error Function
function  z(x::Matrix{Int64}, q::Vector{Int64}, p::Vector{Int64}, N::Int64)
   # S is the number of students, N is the number of courses
   # x is the SxN allocation matrix
   # q is the Nx1 course capacity vector
   # p is the Nx1 price vector
   zer = zeros(N)        #Create empty Nx1 vector of clearing errors
   numstud = transpose(sum(x, 1)) #Create Nx1 vector with the number of students enrolled in each course.
   for i in 1:N        #For every course
       if p[i] > 0     #As long as the price in this course is positive.
           zer[i] = numstud[i] - q[i]
       else
           zer[i] = max(numstud[i] - q[i], 0)
       end
   end
   return zer
end

#TEST
x = [1 0 1;
     1 0 1;
     1 0 1;
     0 0 1;
     1 1 0;
     1 1 1]
q = [4;3;3]
N = 3
p = [30; 0; 50]


z(x, q, p, N)