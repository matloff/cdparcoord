\name{draw}
\alias{draw}

\title{
    Draw parallel coordinates.
}

\description{
    Takes the output of tupleFreqs, which has the rightmost column denoting
    frequency of each tuple, and draws a parallel coordinates plot. The recommended
    method of drawing is through interactivedraw. 
}

\usage{
    draw(partial, name, labelsOff, savePlot=FALSE)
}

\arguments{
    \item{partial}{
        The dataset after processing from tupleFreqs().
    }
    \item{name}{
        The name for the plot.
    }
    \item{labelsOff}{
        Whether or not you'd like to have labels. By default, labels are disabled.
    }
    \item{savePlot}{
        Whether or not you'd like to save to a file instead of immediately displaying.
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}

\examples{
    library(cdparcoord)
    data(smallexample)
    # Grab the 5 most significant tuples. 
    partial <- tupleFreqs(smallexample)
    \dontrun{
        draw(partial, name="Small Demo Example")
    }
}
