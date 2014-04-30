# Load Libraries
library(doParallel) # for parallel processing
library(tcltk2)  # for the popup status window

# Test Parameters
runs <- 5 # number of times to repeat experiment
obs_list <- c(50000, 100000, 150000, 200000) # num obs to generate
cores_list <-c(1,2,3,4,5,6,7,8,9,10) # number of cores to use

# total iterations to make
total <- runs * length(obs_list) * length(cores_list)

# Launch Progress Bar
pb <- tkProgressBar(title = "Parallel Processing Test", min = 0,
                    max = total, width = 1000)

result.df <- data.frame()
experiment_start <- Sys.time() 
grand_iterator <- 1 
for (i in 1:runs) {
  for (cases in obs_list) {
    for (cores in cores_list) {
      
      # impatience is a virture, so I want to see that it's moving along
      elapsed_time <- difftime(Sys.time(), experiment_start, units = "mins")
      setTkProgressBar(pb, grand_iterator, 
                       label=paste("Elapsed Time:",round(elapsed_time,1),
                                   "minutes",
                                   round(grand_iterator/total*100, 1),
                                   "% Complete --- ",
                                   "Currently generating",
                                   prettyNum(cases,big.mark=",",scientific=F),
                                   "random numbers using", cores, "cores")
                       )
      
      # tell the machine how many cores to use
      cluster <- makeCluster(cores)
      registerDoParallel(cluster)
      
      # reset iteration time just prior to executing the parallelized loop
      t1 <- Sys.time()
      # the parallelization step, note foreach and %dorpar%
      result.vec <- foreach(i = 1:100, .combine=c) %dopar% {
        rnorm(cases, mean = 10, sd = 30)
      }
      # get the difference immedidately after the parallel loop
      difft <- difftime(Sys.time(), t1, units = "secs")
      result.df <- rbind(result.df, c(cores, cases, difft))
      
      # killing the current cluster is needed before registering another
      stopCluster(cluster)
      
      # only used in the progress bar
      grand_iterator <- grand_iterator + 1

} } }

experiment_end <- Sys.time()
experiment_time <- difftime(experiment_end, experiment_start, units = "mins")
experiment_time

# closes the progress bar
close(pb) 

df <- result.df
colnames(df) <- c("cores","nobs","time")

library(ggplot2)

# Boxpolt version
g <- ggplot(df,aes(x=factor(cores),y=time,fill=factor(nobs)))
g <- g + geom_boxplot() + geom_jitter()
g

# Line chart
g <- ggplot(df,aes(x=factor(cores),y=time,group=factor(nobs),color=factor(nobs)))
g <- g + geom_line(stat="summary", fun.y = "mean") + geom_jitter()
g