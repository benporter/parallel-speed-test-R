parallel-speed-test-R
=====================

Test the speed of your machine using a different number of cores for parallel processing

=====================

Libraries:
 - doParallel (from Revolution Analytics for parallelization)
 - tcltk2 (to build a progress bar to monitor the progress)

This code was inspired by the <a href="http://rcrastinate.blogspot.com/2014/03/hyperthreading-ftw-testing.html">"Hyperthreading FTW? Testing parallelization performance in R"</a> post from the <a href="http://rcrastinate.blogspot.com/">Rcrastinate blog</a>.

My primary additions were the progress bar from the tcltk2 package and two ggplots at the end.

=====================

Progress Bar: Primary Components

<img src="http://github.com/benporter/parallel-speed-test-R/blob/master/parallelscreenshot.jpeg.png?raw=true" alt="Progress Bar" title="Progress Bar" />

Initialize with the progress bar with a title and parameters for the smallest and largest values to expect

    # Test Parameters
    runs <- 5 # number of times to repeat experiment
    obs_list <- c(50000, 100000, 150000, 200000) # num obs to generate
    cores_list <-c(1,2,3,4,5,6,7,8) # number of cores to use

    # total iterations to make
    total <- runs * length(obs_list) * length(cores_list)

    # Launch Progress Bar
    pb <- tkProgressBar(title = "Parallel Processing Test", min = 0,max = total, width = 1000)
    
In the middle of the for loop, update the progress bar

    setTkProgressBar(pb, grand_iterator, 
                       label=paste("Elapsed Time:",round(elapsed_time,1),
                                   "minutes",
                                   round(grand_iterator/total*100, 1),
                                   "% Complete --- ",
                                   "Currently generating",
                                   prettyNum(cases,big.mark=",",scientific=F),
                                   "random numbers using", cores, "cores")

Notice how overzelous you can get on the text you want to display in the progress bar.  I choose to fill it full of info for initial debugging purposes to see where the algoritm gets stuck.

The last step is to close the progress bar when you are done.

    close(pb)
    
=====================

Parallelization:  Primary Components

Determine the number of clusters to use.  The <i>cores</i> variable is a user defined choice.  My machine has four cores, with hyperthreading, so it continue to get gains up to 8 cores.

      cluster <- makeCluster(cores)
      registerDoParallel(cluster)
      
Execute your function with a <i>foreach</i> loop from the doParallel package, and put the %DOPAR% before the brackets.

      result.vec <- foreach(i = 1:100, .combine=c) %dopar% {
        rnorm(cases, mean = 10, sd = 30)
      }

Before running another iteration of the loop with a different value for the number of cores, reset the cores option.

    stopCluster(cluster)

Results of the experiment:

One way to view the data, via a set of 4 boxplots

<img src="https://github.com/benporter/parallel-speed-test-R/blob/master/boxplot.png?raw=true" alt="Box Plot" title="Box Plot" />

Another way to view the same results, which comes out a bit clearer

<img src="https://github.com/benporter/parallel-speed-test-R/blob/master/linechart.png?raw=true" alt="Line Chart" title="Line Chart" />

