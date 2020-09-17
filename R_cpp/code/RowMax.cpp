#include <Rcpp.h> 

using namespace Rcpp;
// [[Rcpp::export]]
NumericVector row_max(NumericMatrix m) { 
  int nrow = m.nrow();
  NumericVector max(nrow);
  
  for(int i=0; i<nrow ;i++){
    max[i] = Rcpp::max( m(i, _) ); 
  }

  return max;
}

