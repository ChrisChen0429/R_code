library(inline)
library(Rcpp)

# integer vector
## example 1
src <- '
Rcpp::IntegerVector epn(4);
epn[0] = 6;
epn[1] = 14;
epn[2] = 496;
epn[3] = 8182;
return epn;
'

fun <- cxxfunction(signature(),src,plugin = 'Rcpp')
fun()


## example 2
src <- "
Rcpp::IntegerVector vec(vx);
int prod = 1;
for (int i=0; i<vec.size();i++){
  prod *= vec[i];
}
return Rcpp::wrap(prod);
"
fun <- cxxfunction(signature(vx='integer'),src,plugin = 'Rcpp')
fun(1:10)

src <- '
Rcpp::IntegerVector vec(vx);
int prod = std::accumulate(vec.begin(),vec.end(),1,std::multiplies<int>());
return Rcpp::wrap(prod);
'
fun <- cxxfunction(signature(vx='integer'),src,plugin = 'Rcpp')
fun(1:10)



# Numeric Vector
## example 1
src <- '
Rcpp::NumericVector vec(vx);
double p = Rcpp::as<double>(dd);
double sum = 0.0;
for (int i =0; i < vec.size();i++){
  sum += pow(vec[i],p);
}
return Rcpp::wrap(sum);
'

fun <- cxxfunction(signature(vx='numeric',dd='numeric'),src,plugin = 'Rcpp')
fun(1:4,2)
fun(1:4,2.2)


## example 2
#### does not work
src <- '
Rcpp::NumericVector invec(vx);
Rcpp::NumericVector outvec(vx);
for (int i = 0; i < invec.size(); i ++){
  outvec[i] = log(invec[i]);
}
return outvec;
'
fun <- cxxfunction(signature(vx='numeric'),src,plugin = 'Rcpp')
x <- seq(1,3,1)
cbind(x,fun(x))

#### clone method
src <- '
Rcpp::NumericVector invec(vx);
Rcpp::NumericVector outvec = Rcpp::clone(vx);
for (int i = 0; i < invec.size(); i ++){
  outvec[i] = log(invec[i]);
}
return outvec;
'
fun <- cxxfunction(signature(vx='numeric'),src,plugin = 'Rcpp')
x <- seq(1,3,1)
cbind(x,fun(x))


###### Rcpp sugar
src <- '
Rcpp::NumericVector invec(vx);
Rcpp::NumericVector outvec = log(vx);
return outvec;
'
fun <- cxxfunction(signature(vx='numeric'),src,plugin = 'Rcpp')
x <- seq(1,3,1)
cbind(x,fun(x))


## example 3: matrix
src <- 'Rcpp::NumericVector mat =
  Rcpp::clone<Rcpp::NumericMatrix>(mx);
  mat = sqrt(mx);
return mat;'
fun <- cxxfunction(signature(mx="numeric"), src,
                   plugin="Rcpp")
orig <- matrix(1:9,3,3)
fun(orig)


## example 4
src <- '
arma::mat m1 = Rcpp::as<arma::mat>(mx);
arma::mat m2 = m1 + m1;
arma::mat m3 = m1 * 2;
return Rcpp::List::create(m1, m2, m3); '
fun <- cxxfunction(signature(mx="numeric"), src,
                   plugin="RcppArmadillo")
mat <- matrix(1:9, 3, 3)
fun(mat)


src <- '
NumericVector x1(xs);
NumericVector x2(Rcpp::clone(xs));
x1[0] = 22;
x2[1] = 44;
return(DataFrame::create(Named("orig", xs),
                           Named("x1", x1),
                           Named("x2", x2)));'
fun <- cxxfunction(signature(xs="numeric"),body=src, plugin="Rcpp")
fun(seq(1.0, 3.0, by=1.0))


## logical vector
src <- '
Rcpp::LogicalVector v(6);
v[0] = v[1] = false;
v[2] = true;
v[3] = R_NaN;
v[4] = R_PosInf;
v[5] = NA_REAL;
return v;
'
fun <- cxxfunction(signature(),src, plugin = 'Rcpp')
fun()

identical(fun(),c(FALSE,FALSE,TRUE,rep(NA,3)))


## characterVector
src <- '
Rcpp::CharacterVector v(3);
v[0] = "The quick brown";
v[1] = "fox";
v[2] = R_NaString;
return v;
'
fun <- cxxfunction(signature(),src, plugin = 'Rcpp')
fun()

## Named
src1 <- 'Rcpp::NumericVector x = 
          Rcpp::NumericVector::create(
            Rcpp::Named("mean")=1.23,
            Rcpp::Named("dim")=42,
            Rcpp::Named("cnt")=12);
        return x;
'

src2 <- 'Rcpp::NumericVector x = 
          Rcpp::NumericVector::create(
            _["mean"]=1.23,
            _["dim"]=42,
            _["cnt"]=12);
        return x;
'

fun <- cxxfunction(signature(),src1,plugin = 'Rcpp')
fun()

fun <- cxxfunction(signature(),src2,plugin = 'Rcpp')
fun()

##  List (GenericVector)


## DataFrame
src <- '
Rcpp::IntegerVector v = 
      Rcpp::IntegerVector::create(7,8,9);
std::vector<std::string> s(3);
s[0] = "x";
s[1] = "y";
s[2] = "z";
return Rcpp::DataFrame::create(Rcpp::Named("a")=v,
                               Rcpp::Named("b")=s);
' 
fun <- cxxfunction(signature(),src,plugin = 'Rcpp')
fun()


## function
#### example 1
src <- '
Function sort(x);
return sort(y,Named("decreasing",true));
'
fun <- cxxfunction(signature(x="function",
                             y="ANY"),
                   src,plugin = "Rcpp")
fun(sort,sample(1:5,10,TRUE))
fun(sort,sample(LETTERS[1:5],10,TRUE))


#### example 2
src <- '
RNGScope scp;
Rcpp::Function rt("rt");
return rt(5,3);
'
fun <- cxxfunction(signature(),src,plugin = 'Rcpp')
fun()


## S4
src <-'
RObject y(x);
List res(3);
res[0] = y.isS4();
res[0] = y.hasSlot("z");
res[0] = y.slot("z");
return res;
'
f1 <- cxxfunction(signature(x='any'),src,plugin = 'Rcpp')
f1(123)

src <- '
S4 foo(x);
foo.slot(".Data")="fooo";
return foo;
'
f2 <- cxxfunction(signature(x='any'),src,plugin = 'Rcpp')
f2(123)

## Rmath
sourceCpp("mypnorm.cpp")
mypnorm(xx = c(1,2,3))
        