# Vector
rm(list=ls())
quad_v <- function(a = 1, b, c) {
  problems <- c(a=! is.numeric(a), b=! is.numeric(b), c =! is.numeric(c))
  if(sum(problems) >= 1) stop("Error with following input: ", paste0(names(problems)[problems], collapse = ","))
  form <- b^2 - 4*a*c
  if (form > 0) {
    x1 <- c((-b + sqrt(form)) / (2*a), (-b - sqrt(form)) / (2*a))
  } else if (form == 0) {
    x1 <- (-b / (2*a))
  } else {
    x1 <- numeric(0)
  }
  
  out <- paste0(c(a, b, c, x1))
  out
}


# Character
quad_c <- function(a = 1, b, c) {
  problems <- c(a=! is.numeric(a), b=! is.numeric(b), c =! is.numeric(c))
  if(sum(problems) >= 1) stop("Error with following input: ", paste0(names(problems)[problems], collapse = ","))
  form <- b^2 - 4*a*c
  
  if (form > 0) {
    x1 <- c((-b + sqrt(form)) / (2*a), (-b - sqrt(form)) / (2*a))
    char <- paste0("Two answers:", x1[1], "and", x2[2])
  } else if (form == 0) {
    x3 <- -b / (2*a)
    char <- paste0("One answer:", x3)
  } else {
    char <- "None."
  }
  
  out <- paste0("Inputs: a = ", a, " b = ", b, " c = ", c, " Answer: ", char)
out
}

#List
quad_l <- function(a = 1, b, c) {
  problems <- c(a=! is.numeric(a), b=! is.numeric(b), c =! is.numeric(c))
  if(sum(problems) >= 1) stop("Error with following input: ", paste0(names(problems)[problems], collapse = ","))
  form <- b^2 - 4*a*c
  x1 <- if (form > 0){
    c((-b + sqrt(form)) / (2*a), (-b - sqrt(form)) / (2*a))
  } 
  else if (form == 0){
    (-b / (2*a))
  }
  else{"No answer"
  } 
  
  out <- list(input = paste0("a = ", a, " b = ", b, " c = ", c), answer = x1)
  out
}
quad_c("test",5,6)
quad_l(4,5,"test")
quad_v(4,"test",6)
