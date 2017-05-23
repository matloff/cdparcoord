\name{draw}
\alias{draw}

\title{
Draw parallel coordinates.
}

\description{
Takes the output of partialNA, which has the rightmost column denoting
frequency of each tuple, and draws a parallel coordinates plot.
}

\usage{
draw(partial, name, labelsOff)
}

\arguments{
    \item{partial}{
        The dataset after processing from partialNA().
    }
    \item{name}{
        The name for the plot.
    }
    \item{labelsOff}{
        Whether or not you'd like to have labels. By default, labels are disabled.
    }
}

\author{
Norm Matloff <matloff@cs.ucdavis.edu>, Harrison Nguyen <hhnguy@ucdavis.edu>, and Vincent Yang <vinyang@ucdavis.edu>
}

\examples{
    file <- system.file("data", "smallexample.csv", package="freqparcoord.cd")
    dataset <- read.table(file, header=TRUE, sep=";", na.strings="")
    # Grab the 5 most significant tuples. 
    partial <- partialNA(dataset)
    draw(partial, "Small Demo Example")
}
