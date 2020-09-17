library(tidyverse)
library(nycflights13)
library(gapminder)
library(Lahman)
#tidyverse_update()

data(iris)
### select: choose the column of the dataframe (cannot use logic)
select(iris,1,2)
select(iris,c(1,2))
select(iris,c(Sepal.Length,Sepal.Width))
select(iris,-Species)
select(iris,grepl("Sepal",colnames(iris))) ## cannot use logic
select(iris,grep("Sepal",colnames(iris)))

##### auxiliary function for selection
select(iris,contains(".")) ## same as the one above
select(iris,starts_with("Sepal")) ##same as the one above
select(iris,ends_with("th")) 
select(iris,contains("."))
select(iris,everything())
select(iris,one_of(c("Sepal",'Species'))) ##not just contain
select(iris,matches(".t.")) #regular expression
select(iris,num_range("x",1:5)) ## x1,x2,x3,x4,x5


### filter: filter rows
filter(iris,Sepal.Length>5)  ## filter rows by logic
slice(iris,1:5) ## slice rows by index


### distinct 
distinct(iris)



### sample
sample_frac(iris, 0.1, replace = T)
sample_n(iris,10,replace = F)


## arrange 
arrange(iris,Sepal.Length)
arrange(iris,desc(Sepal.Length))
arrange(iris,Sepal.Length,Sepal.Width)


## merge/join
df1 <- data.frame("id1"=1:10,"square"=(1:10)^2)
df2 <- data.frame("id2"=5:15,"trible"=(5:15)^3)
