library(inline)
library(Rcpp)
## Vector convolution
src <- '
  Rcpp::NumericVector xa(a);
  Rcpp::NumericVector xb(b);
  int n_xa = xa.size(), n_xb = xb.size();
  
  Rcpp::NumericVector xab(n_xa + n_xb - 1);
  for (int i = 0; i < n_xa; i++){
    for (int j = 0; j < n_xb; j++){
      xab[i+j] += xa[i] * xb[j];
    }
  }
  return xab;
'

convoluation <- cxxfunction(signature(a='numeric',b='numeric'),
                            src,plugin='Rcpp',verbose = TRUE)
convoluation <- rcpp(signature(a='numeric',b='numeric'),src)

convoluation(1:4,2:5)


## includes example
inc <- '
template <typename T>
class square : public std::unary_function<T,T>{
  public: 
    T operator() (T t) const{ return t*t;}
};'

src <- '
double x = Rcpp::as<double>(xs);
int i = Rcpp::as<int>(is);
square<double> sqdbl;
square<int> sqint;
Rcpp::DataFrame df = Rcpp::DataFrame::create(Rcpp::Named("x",sqdbl(x)),
                                             Rcpp::Named("i",sqdbl(i)));
return df;'

fun <- cxxfunction(signature(xs="numeric",is="integer"),
                   body=src,include=inc,plugin = 'Rcpp')
fun(2.2,3L)


## plugin fastLm in RcppArmadillo
src <- '
Rcpp::NumericVector yr(ys);
Rcpp::NumericMatrix Xr(Xs);
int n = Xr.nrow(), k = Xr.ncol();
arma::mat X(Xr.begin(),n,k,false);
arma::colvec y(yr.begin(),yr.size(),false);
arma::colvec coef = arma::solve(X,y); //fit y~x
arma::colvec res = y - X*coef; //residual
double s2 = std::inner_product(res.begin(),res.end(),
                                res.begin(),double())
                                /(n-k);
arma::colvec se = arma::sqrt(s2*
                  arma::diagvec(arma::inv(arma::trans(X)*X)));
return Rcpp::List::create(Rcpp::Named("coef")=coef,
                          Rcpp::Named("se")=se,
                          Rcpp::Named("df")=n-k);
'

Lm <- cxxfunction(signature(ys='numeric',Xs='numeric'),
                  src, plugin = 'RcppArmadillo')
Lm(ys = freeny.y,Xs = freeny.x)


## GNU/GSL: make a plugin
gslrng <- '
int seed = Rcpp::as<int>(par);
gsl_rng_env_setup();
gsl_rng * r = gsl_rng_alloc(gsl_rng_default);
gsl_rng_set (r, (unsigned long) seed);
double v = gsl_rng_get(r);
gsl_rng_free(r);
return Rcpp::wrap(v);
'

plug <- Rcpp::Rcpp.plugin.maker(include.before = '#include <gsl/gsl_rng.h>',
                                libs = paste("-L/usr/local/lib/R/site-library/Rcpp/lib ",
                                "-lRcpp -Wl, -rpath,",
                                "/usr/local/lib/R/site-library/Rcpp/lib ",
                                "-L/usr/lib -lgsl -lgslcblas -lm",sep=""))
registerPlugin('gslDemo',plug)
fun <- cxxfunction(signature(par='numeric'),
                   gslrng,plugin = 'gslDemo')
fun(0)

## Rcpp attritubes

cpptext <- '
int fibonacci(const int x){
  if (x<2) return(x);
  return(fibonacci(x-1) + fibonacci(x-2));
}'
fibcpp <- cppFunction(cpptext)
fibcpp(10)


code <- '
# include <gsl/gsl_const_mksa.h> // decl of constants

std::vector<double> volumes(){
  std::vector<double> v(5);
  v[0] = GSL_CONST_MKSA_US_GALLON;
  v[1] = GSL_CONST_MKSA_CANADIAN_GALLON;
  v[2] = GSL_CONST_MKSA_UK_GALLON;
  v[3] = GSL_CONST_MKSA_QUART;
  v[4] = GSL_CONST_MKSA_PINT;
  return v;
}
'

gslVolums <- cppFunction(code,depends = 'RcppGSL')
gslVolums()


## catch exception
cppFunction('
            int fun2(int dx){
              if(dx>10){throw std::range_error("too big");}
              return dx*dx;
}')
fun2(3)
fun2(11)
