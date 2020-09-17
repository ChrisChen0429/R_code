#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
void hello()
{
  Rprintf("hello, world!\n");
}