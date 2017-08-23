\name{interactivedraw}
\alias{interactivedraw}

\title{
Draw parallel coordinates on an interactive plotly plot.
}

\description{
Takes the output of tupleFreqs, which has the rightmost column denoting
frequency of each tuple, and draws an interactive parallel coordinates plot.
These plots are useful in that you can drag columns to investigate further
relationships and also select a segment on a vertical axis to selectively
view patterns.

You can save the graph from the window.

Each axis is independent, and has its max/min based off of its own data.
}

\usage{
    interactivedraw(pna, name="Interactive Parcoords", accentuate=NULL, 
                    accval=100, differentiate=FALSE)
}

\arguments{
    \item{pna}{
        The dataset after processing from tupleFreqs().
    }
    \item{name}{
        The name for the plot.
    }
    \item{accentuate}{
        The column and value you want to accentuate.
    }
    \item{accval}{
        The amount to accentuate.
    }
    \item{differentiate}{
        Whether or not you want to use random coloring. This will help you find where
        lines differ, but will not differentiate frequencies by color. By default,
        this is FALSE.
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}

\examples{
    # Drawing an interactive parallel coordinates plot without categorical variables
    data(smallexample)
    partial <- tupleFreqs(smallexample)
    interactivedraw(partial)
}
