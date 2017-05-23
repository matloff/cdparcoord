\name{partialNA}
\alias{partialNA}

\title{
    Account for NA values in datasets.
}

\description{
Calculate the significance of each tuple. Tuples with NA values will 
count for less, but weigh toward everything that has existing numbers
in common with it. 

In a data set with (5, 3, 2), (5, NA, 2), and (6, NA, 2), the (5, 3, 2)
will count toward (5, 3, 2) with weight 1. Then, the (5, NA, 2) counts toward
(5, 3, 2) with weight 2/3, because 2 of the 3 variables are the same. Then, 
the (6, NA, 2) will count toward nothing. 
}

\usage{
partialNA(dataset, n)
}

\arguments{
    \item{dataset}{
        The dataset to process. There may be NA values in this dataset.
    }
    \item{n}{
        The number of significant rows to return. By default, this returns the top 5.
    }
}

\author{
Norm Matloff <matloff@cs.ucdavis.edu>, Harrison Nguyen <hhnguy@ucdavis.edu>, and Vincent Yang <vinyang@ucdavis.edu>
}

\examples{
    file <- system.file("data", "smallexample.csv", package="freqparcoord.cd")
    dataset = read.table(file, header=TRUE, sep=";", na.strings="")
    partial <- partialNA(dataset)  
    partial
}
