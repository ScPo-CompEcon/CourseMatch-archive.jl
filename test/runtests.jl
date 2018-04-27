using CourseMatch
using Base.Test

# write your own tests here

@testset "demand function tests" begin
    @testset "unimodal preferences" begin
    #Here I have one student, 3 available classes, one being striclty preferred to the other two and it is required to enroll in one class in total.
    #The student has the budget such that they can afford any class under the randomly chosen prices. The test checks if the demand functions does indeed
    #select the most preferred one in this context of utmost simplicity.
    p = rand(3)
    pref = [[100 0 0 ; 0 0 0; 0 0 0]] #one class prefered
    budg = [100] #arbitrary budget
    req = [1] #1 class is required
    solution = demand(p, pref, budg, req)
    @test solution["ind_demands"][1] == [1, 0, 0]
    @test solution["total_demand"] == [1, 0, 0]
    end

    @testset "unaffordable most preferred course" begin
    #Here I have one student, 3 available classes, and it is required to enroll in one class in total. The student has a stric ordering on the three classes
    #but they cannot afford their most preferred course. The test checks if the demand functions does indeed
    #select the most preferred affordable one in this simple context.
    p = rand(3)
    p[1] = 101
    pref = [[100 0 0 ; 0 50 0; 0 0 0]] #one class prefered
    budg = [100] #arbitrary budget
    req = [1] #1 class is required
    solution = CourseMatch.demand(p, pref, budg, req)
    @test solution["ind_demands"][1] == [0, 1, 0]
    @test solution["total_demand"] == [0, 1, 0]
end

    @testset "substitutable classes" begin
    #Here I have one student, 3 available classes, and it is required to enroll in two classes in total. The student has a stric ordering on the three classes
    #but they have a strong preference over not taking their two most preferred ones together such that they prefer to take their preferred one
    #and their least preferred one. The test checks if the demand functions does indeed select
    #the most preferred combination of courses in this context.
    p = rand(3)
    pref = [[100 -100 0 ; -100 50 0; 0 0 0]]
    budg = [100] #arbitrary budget
    req = [2] #2 classes are required
    solution = demand(p, pref, budg, req)
    @test solution["ind_demands"][1] == [1, 0, 1]
    @test solution["total_demand"] == [1, 0, 1]
end
    @testset "identical students" begin
    #Here I have two strictly identical students, 3 available classes, and it is required to enroll in one classes in total. The test checks if the demand
    #functions does indeed give the same demand for the two students.
    p = rand(3)
    pref = Matrix(diagm(rand(0:100, 3)))
    pref = [pref, pref]
    budg = rand(150:200, 1)[1]
    budg = [budg, budg]
    req = [1, 1] #1 class is required
    solution = CourseMatch.demand(p, pref, budg, req)
    @test solution["ind_demands"][1] == solution["ind_demands"][2]
    @test solution["total_demand"] == 2*solution["ind_demands"][2]
end
end
