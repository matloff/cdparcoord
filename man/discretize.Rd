\name{discretize}
\alias{discretize}

\title{
    A small example demonstrating discretize.
}

\description{
    A small example showing how the freqparcoord.cd package discretizes data.
}

\usage{
discretize(dataset, input)
}

\arguments{
    \item{dataset}{
        The dataset to discretize.
    }
    \item{input}{
        Specifies what columns to partition, the number of partitions, and labels for each partition.
        The outermost list holds each column's specifications. The inner lists hold
        the name of the column, the number of partitions, and a list of labels for each partition.
    }
}

\author{
Norm Matloff <matloff@cs.ucdavis.edu>, Harrison Nguyen <hhnguy@ucdavis.edu>, and Vincent Yang <vinyang@ucdavis.edu>
}

\examples{
    # load freqparcoord to get the mlb data set
    library(freqparcoord)
    data(mlb)
    # Get the Height, Weight, Age, and Position of Players
    m <- mlb[,4:7]
    inp1 <- list("name" = "Height", 
                 "partitions"=4, 
                 "labels"=c("low", "lowmid", "highmid", "high"))

    inp2 <- list("name" = "Weight", 
                 "partitions"=3, 
                 "labels"=c("light", "med", "heavy"))

    inp3 <- list("name" = "Age", 
                 "partitions"=2, 
                 "labels"=c("young", "old"))

    # Create one list to pass everything to discretize()
    discreteinput <- list(inp1, inp2, inp3)

    # At this point, all of the data has been discretized
    discretizedmlb <- discretize(m, discreteinput)

    # Account for NA values and weigh values; interactively plot
    discparcoord(discretizedmlb, interactive=TRUE)
}
