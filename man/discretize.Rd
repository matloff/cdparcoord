\name{discretize}
\alias{discretize}

\title{
    Convert continuous variables to discrete data.
}

\description{
    A small example showing how the cdparcoord package discretizes data.
}

\usage{
    discretize(dataset, input, ndigs=0, nlevels=10)
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
    \item{ndigs}{
        Labels for default partitioning if input is not supplied as a list.
    }
    \item{nlevels}{
        The number of partitions to have. By default, this is 10.
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}

\examples{
    # load freqparcoord to get the mlb data set
    library(freqparcoord)
    data(mlb)
    # Get the Height, Weight, Age, and Position of Players
    m <- mlb[,4:7]

    inp1 <- list("name" = "Height",
                 "partitions"=4,
                 "labels"=c("short", "shortmid", "tallmid", "tall"))

    inp2 <- list("name" = "Weight",
                 "partitions"=3,
                 "labels"=c("light", "med", "heavy"))

    inp3 <- list("name" = "Age",
                 "partitions"=3,
                 "labels"=c("young", "med", "old"))

    # Create one list to pass everything to discretize()
    discreteinput <- list(inp1, inp2, inp3)

    # At this point, all of the data has been discretized
    discretizedmlb <- discretize(m, discreteinput)

    # Account for NA values and weigh values; interactively plot
    discparcoord(discretizedmlb, interactive=TRUE)
}
