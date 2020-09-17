library(Rcpp)
sourceCpp(file = "hello.cpp")
hello()


## including C++ inline
cppFunction('int add(int x, int y, int z){
  int sum = x + y + z;
  return sum;
}')
add(1,2,3)

sourceCpp(file = "RowMax.cpp")

