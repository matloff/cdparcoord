\name{clsPartialNA}
\alias{clsPartialNA}

\title{
    Compute tuple frequency counts, and optionally account for NA values
    in parallel.
}

\description{
    This works the same as partialNA but in parallel.
    Calculate the frequency of each tuple, and return the most- or
    least-frequent tuples.  Optionally, tuples with NA values will count
    for less, but weigh toward everything that has existing numbers in
    common with it.
}

\usage{
    clsPartialNA(cls=NULL, dataset, k=5, NAexp=1, countNAs=FALSE)
}

\arguments{
    \item{cls}{
        The cluster to use to process. If not supplied, it generates its own cluster.
    }
    \item{dataset}{
        The dataset to process, a data frame or data.table.
    }
    \item{k}{
        The number of tuples to return. These will be the \code{k} most
        frequent tuples, unless \code{k} is negative, in which case the
        least-frequent tuples will be returned.  The latter is useful
        for hunting for outliers.
    }
    \item{NAexp}{
        Scale NA signifiance. This is experimental and may be extremely slow.
    }
    \item{countNAs}{
        Whether or not you want to count NA values.
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}

\details{
    This is the workhorse function in the package, calculating frequency
    counts to be used in the graphs.

    The data will be converted into a data.table if it is not already in
    that form.  For this and other reasons, it is advantageous to have the
    data in that form to begin with, say by using \code{fread} to read the data.

    Optionally, tuples that partially match a full tuple pattern except for NA
    values will add a partial count to the frequency count for the full
    pattern.  If for instance the data consist of 8-tuples and a row in the
    data matches a given 8-tuple pattern in 7 of 8 components, this row
    would add a count of 7/8 to the frequency for that pattern.  To reduce
    this weight, use a value greater than 1.0 for \code{NAexp}.  If that
    value is 2, for example, the 7/8 increment will be 7/8 squared.
}

\examples{
    data(Titanic_Passengers)
    # Find frequencies in parallel
    discparcoord(Titanic_Passengers, inParallel=TRUE)
}
