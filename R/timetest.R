library(pracma)

# This program investigates runtimes of various parallel coordinates packages.
# List of parallel coordinates packages:

# freqparcoord.cd
# freqparcoord
# ggparcoord unavailable for R version 3.4
# parcoord unavailable for R version 3.4
# rggobi unavailable due to RGtk2 unavailablity (RGtk2 doesn't work either)

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


print("Freqparcoord time: ")
test_load("freqparcoord")

print("Freqparcoord.cd time: ")
test_load("freqparcoord.cd")

print("ggparallel time: ")
test_load("ggparallel")

######### Plotting Tests
######### Test data sets #######
# Load all data sets and libraries
library(freqparcoord.cd)
library(freqparcoord)
library(ggparallel)
library(lattice)
data(hrdata)


# Plot a data set given an input dataset and a library
timed_plot <- function(package_name, dataset){
    if (strcmp("freqparcoord.cd", package_name)){
        # plot with freqparcoord.cd
        start_time <- proc.time()
        pna <- partialNA(dataset)
        discparcoord(pna)
        print(proc.time() - start_time)
    }
    else if(strcmp("ggparallel", package_name)){
        start_time <- proc.time()
        #dataset <- head(dataset) # Displays weird/incorrectly unless we do this
        ggparallel(colnames(dataset), data=dataset)
        print(proc.time() - start_time)
    }
    else if (strcmp("freqparcoord", package_name)){
        start_time <- proc.time()
        freqparcoord(dataset, m=nrow(dataset))
        print(proc.time() - start_time)
    }
    else if (strcmp("lattice", package_name)){
        start_time <- proc.time()
        parallelplot(dataset)
        print(proc.time() - start_time)
    }
    else {
        print("Unavailable package")
    }
}

# Run a set of small datasets on all plotting packages
time_datasets <- function(dataset, isNumerical=FALSE){
    print("Freqparcoord.cd ")
    timed_plot("freqparcoord.cd", dataset)

    if (isNumerical){
        print("Freqparcoord ")
        timed_plot("freqparcoord", dataset)
    }

    print("lattice")
    timed_plot("lattice", dataset)

    print("ggparallel")
    timed_plot("ggparallel", dataset)

}

cat("\nSmall Datasets:\n")
data(Titanic_Passengers)
Titanic_Passengers$X=NULL
time_datasets(Titanic_Passengers)

cat("\nMedium Dataset:\n")
time_datasets(hrdata)

data(prgeng)
time_datasets(prgeng, isNumerical=TRUE)

cat("\nLarge Dataset:\n")
# MSD

