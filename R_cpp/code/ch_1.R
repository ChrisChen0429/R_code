library(Rcpp)
library(compiler)
library(inline)
library(rbenchmark)
xx <- faithful$eruptions
fit1 <- density(xx)
fit1
plot(fit1)


## confidence interval using bootstrap
xx <- faithful$eruptions
fit1 <- density(xx)
fit2 <- replicate(10000,{x <- sample(xx,replace = TRUE);
                  density(x, from=min(fit1$x),to=max(fit1$x))$y})
dim(fit2)
fit3 <- apply(fit2,1,quantile,c(0.025,0.975))
dim(fit3) 
plot(fit1,ylim=range(fit3))
polygon(c(fit1$x,rev(fit1$x)),
        c(fit3[1,],rev(fit3[2,])),
        col = 'grey', border = F)
lines(fit1)





# Example 1: fabonacci
fibR <- function(n){
  if(n==0) return(0)
  if(n==1) return(1)
  return(fibR(n-1)+fibR(n-2))
}

sourceCpp("fibonacci.cpp")

## solution 2
mfibR <- local({memo <- c(1,1,rep(NA,1000))
               f <- function(x){
                 if (x==0) return(0)
                 if (x<=0) return(NA)
                 if (x>length(memo)) stop("x too big for implementation")
                 if (!is.na(memo[x])) return(memo[x])
                 else{
                   ans <- f(x-2) + f(x-1)
                   memo[x] <<- ans  
                 }
                 ans}})


mincltxt <- '
#include <algorithm>
#include <vector> 
#include <stdexcept>
#include <cmath>
#include <iostream>
class Fib{
public: Fib(unsigned int n = 1000){
  memo.resize(n);
  std::fill(memo.begin(),memo.end(),NAN);
  memo[0]=0.0;
  memo[1]=1.0;}

double fibonacci(int x){
  if (x<0) 
    return((double) NAN);
  if (x>=(int) memo.size())
    throw std::range_error(\"x too large for implementation\");
  if (! ::isnan(memo[x]))
    return(memo[x]);
  memo[x] = fibonacci(x-2) + fibonacci(x-1);
  return(memo[x]);
}

private: std::vector<double> memo;
};'

mfibRpp <- cxxfunction(signature(xs="int"),
                        plugin = "Rcpp",
                        includes = mincltxt,
                        body = "int x = Rcpp::as<int>(xs);
                        Fib f;
                        return Rcpp::wrap(f.fibonacci(x-1));")


## solution3
fibRiter <- function(n){
  first <- 0
  second <- 1
  thrid <- 0
  for (i in seq_len(n)){
    thrid <- first + second
    first <- second
    second <- thrid
  }
  return(first)
}

fibRcppIter <- cxxfunction(signature(xs="int"),
                           plugin = "Rcpp",
                           body = "int n = Rcpp::as<int>(xs);
                           double first = 0;
                           double second = 1;
                           double third = 0;
                           for (int i = 0 ; i < n; i++){
                            third = first + second;
                            first = second;
                            second = third;
                           }
                           return Rcpp::wrap(first);
                           ")



## example 2: VAR model
a <- matrix(c(0.5,0.1,0.1,0.5),nrow = 2)
u <- matrix(rnorm(10000),ncol = 2)

rsim <- function(coeff, errors){
  simdata <- matrix(0,nrow(errors),ncol(errors))
  for (row in 2:nrow(errors)){
    simdata[row,] <- coeff %*% simdata[(row-1),] + errors[row,]
  }
  return(simdata)
}
rData <- rsim(a,u)



suppressMessages(require(inline))
code <- '
arma::mat coeff = Rcpp::as<arma::mat>(a);
arma::mat errors = Rcpp::as<arma::mat>(u);
int m = errors.n_rows;
int n = errors.n_cols;
arma::mat simdata(m,n);
simdata.row(0) = arma::zeros<arma::mat>(1,n);
for (int row=1;row<m;row++){
  simdata.row(row) = simdata.row(row-1) * trans(coeff) + errors.row(row);
}
return Rcpp::wrap(simdata);
'

rcppsim <- cxxfunction(signature(a="numeric",u="numeric"),
                       code,
                       plugin = "RcppArmadillo")

rcppData <- rcppsim(a,u)
all.equal(rData,rcppData)

suppressMessages(library(rbenchmark))
e = u
res <- benchmark(rcppsim(a,e),
                 rsim(a,e),
                 columns = c('test','replications',
                             'elapsed','relative','user.self','sys.self'),
                 order="relative")
