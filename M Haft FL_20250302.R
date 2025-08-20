# squared for loop
for (i in 1:10) {
  print(i ^ 2)
}

# Dynamic output method
even_numbers <- (1:25) *2
saved_even_num <- numeric()
for (i in even_numbers) {
  print(saved_even_num)
  saved_even_num <- c(saved_even_num, i^2)
}
saved_even_num

# External Vector method
even_numbers <- (1:25) *2
EV_num <- numeric(length = 25)
for(i in 1:25){
  EV_num[i] <- even_numbers[i]^2
}
EV_num

#While loop
set.seed(1)
ran_num <- c()
sum <- 0
while(sum <= 50){
  sum_num <- sample(0:10, 1)
  ran_num <- c(ran_num, sum_num)
  sum <- sum + sum_num
}
ran_num
sum






