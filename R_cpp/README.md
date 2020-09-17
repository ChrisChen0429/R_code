# Rcpp
This repository is used for saving the code and resources of Rcpp.

### Chapter one:

#### Examples: 

* Simple Example: hellp world (hello.cpp);

* Simple Example: element sum of a vector (ElementSum.cpp);

* Simple Example: max value for each row of a matrix (RowMax.cpp);

* Fibonacci:

1. Fibonacci generation with recursion: fibonacci.cpp;

2. Fibonacci generation with recursion (improve the spead by saving the results): mfibRpp in ch_1.R

3. Fibonacci generation with iteration: fibRcppIter in ch_1.R

* VAR(1) model: rcppsim in ch_1.R;

#### Key notes: 

* Using **inline** (cxxfunction) to add cpp code into R;

* using **rbenchmark** to compare the performance of solutions;

* using **RcppArmadillo** to apply linear algebra.


### Chapter two:

This chapter mainly discuss the issues about compiling the code and some useful package in R for compiling. `SourceCpp`, `evalCpp`, and `cppFunction` are three functions for inline compiling the cpp code in R.

#### Example

* Vector convolution: example of using inline

* example of using include (define structure or class)

* Linear Regression: example of using plugin (RcppArmadillo).

* example of making a plugin (GSL).


### Chapter Three

#### RObject

* IntegerVector

* NumbericVector

* LogicalVector;

* CharacterVector;

* GenericVector;

* ExpressionVector;

* RawVector;

* Function;

* Environment;

* R math package;