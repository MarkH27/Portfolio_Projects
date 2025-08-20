sample <- rnorm(n = 6, mean = 161, sd = 5)
sample
set.seed(812)
reps <- 10
thetas <- rep(NA,reps)
thetas

for(i in 1:reps){
  sample <- rnorm(n = 6, mean = 161, sd = 5)
  sample_mean <- mean(sample)
  thetas[i] <- sample_mean
}
thetas

set.seed(6611)
simres <- sapply(1:1000, function(x) mean( rexp(n=25,rate = 2)))
mean(simres)

hist(simres, main = 'Histogram of Sample Means', xlab = 'Sample Mean')
abline(v=mean(simres), col="blue", lwd=2)



#HOMEWORK
set.seed(2)
samp_size <- c(20,30,40,50)
rate <- c(1.5,2,2.5,3)
x <- data.frame()

for (i in samp_size) {
  for (r in rate) {
    simres <- sapply(1:1000, function(x) mean(rexp(n=i, rate=r)))
    
    mean_simres <- mean(simres)
    sd_simres <- sd(simres)
    lower_per <- as.numeric(quantile(simres, 0.025))
    upper_per <- as.numeric(quantile(simres, 0.975))
    
    x <- rbind(x, data.frame(
      i = i,
      r = r,
      mean_simres = mean_simres,
      sd_simres = sd_simres,
      lower_per = lower_per,
      upper_per = upper_per
    ))
  }
}

print(x)
  