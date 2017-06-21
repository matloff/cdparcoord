library(pracma)

# This program investigates runtimes of various parallel coordinates packages.
# List of parallel coordinates packages:
# freqparcoord.cd
# freqparcoord
# ggparallel
# ggparcoord
# lattice
# rggobi
# parcoord (MASS)
#
# Metrics:
# Large data sets:
#   MSD
#
# Medium data sets:
#
# Small data sets:

# Load a library 10 times and return the avg time it takes
# Timing code: https://stats.idre.ucla.edu/r/faq/how-can-i-time-my-code/
test_load <- function(package_name){
    num_tests = 50
    total_time <- 0
    for (i in 1:num_tests){
        start_time <- proc.time()
        suppressMessages(library(package_name, character.only=TRUE))
        total_time = total_time + (proc.time() - start_time)
        unloadNamespace(package_name)
    }
    total_time/num_tests
}

# Plot a data set given an input dataset and a library
timed_plot <- function(dataset, package_name){
    if (strcmp("freqparcoord.cd", package_name) == 0){
        # plot with freqparcoord.cd
        start_time <- proc.time()
        pna <- partialNA(dataset)
        discparcoord(pna)
        print(proc.time() - start_time)
    }
    else {
        print("Unavailable package")
    }
}

# Run a set of small datasets on all plotting packages
time_small_datasets <- function(){
    print("Freqparcoord.cd hrdata")
    timed_plot("freqparcoord.cd", hrdata)

    print("Freqparcoord hrdata")
    timed_plot("freqparcoord", hrdata)
}

# Load time
#start_time <- proc.time()
#library(freqparcoord)
#freqparcoord_load <- proc.time() - start_time
#
#library(freqparcoord.cd)

print("Freqparcoord time: ")
test_load("freqparcoord")

print("Freqparcoord.cd time: ")
test_load("freqparcoord.cd")

print("ggparallel time: ")
test_load("ggparallel")

# ggparcoord unavailable for R version 3.4
#print("ggparcoord time: ")
#test_load("ggparcoord")

# parcoord unavailable for R version 3.4
#print("parcoord time: ")
#test_load("parcoord")

# rggobi unavailable due to RGtk2 unavailablity (RGtk2 doesn't work either)

######### Test data sets #######
# Load all data sets and libraries
library(freqparcoord.cd)
library(freqparcoord)
library(ggparallel)
data(hrdata)

discparcoord(hrdata)
time_small_datasets()
