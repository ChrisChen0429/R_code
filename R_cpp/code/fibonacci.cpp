#include <Rcpp.h>
using namespace Rcpp;


// [[Rcpp::export]]
int fibonacciRcpp (const int x){
  if (x == 0) return(0);
  if (x == 1) return(1);
  return fibonacciRcpp(x-1) + fibonacciRcpp(x-2);
}

