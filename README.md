# CourseMatch

[![Build status](https://badge.buildkite.com/c42d85291bb037838c362342e2216d25b7886fb105623cbd2a.svg)](https://buildkite.com/sciencespoecon/coursematch)

This is the repo for the `CourseMatch` term project of our course.

## Checklist

- [x] implement a `Student` struct to carry all relevant information
- [x] implement `student`'s demand function: given prices, preferences and constraints, which is the optimal choice of courses
- [x] test demand function
- [x] translate pseudo code of main price search algo from paper (algo 1)
- [ ] test pseudo code translation
- [ ] implement algo 2: refinement of price vector
- [x] implement neighboring price vector function
- [ ] test neighboring price vector function 

## Modus Operandi

* Please **never** push anything onto the `master` branch.
* Please **always** submit a pull request instead.

So:

1. step one should be for everyone to **fork** this repo to your github account.
2. step two should be for everyone to `Pkg.clone` this repo into your julia package directory:
	```julia
	Pkg.clone("https://github.com/ScPo-CompEcon/CourseMatch.jl")
	```
3. load the code with `using CourseMatch`
4. use it! For example by typing `CourseMatch.VERSION`
5. Change it in your editor
6. create a new branch for your work in the repo at `~/.julia/v0.6/CourseMatch` with 
	```bash
	git checkout -b my_new_feature
	git add .
	git commit -m 'I added a new feature'
	git remote add fork git@url_of_your_fork  # look up on your github
	git push fork my_new_feature
	```
7. then go to your fork on github and create a new pull request.


## Style Guide

1. Indent by 4 whitespaces
2. DOCUMENT EACH FUNCTION like here: https://docs.julialang.org/en/stable/manual/documentation/
