\name{partialNA}
\alias{partialNA}

\title{
    Compute tuple frequency counts, and optionallyAccount for NA values.
}

\description{
Calculate the frequency of each tuple, and return the most- or
least-frequent tuples.  Optionally, tuples with NA values will count 
for less, but weigh toward everything that has existing numbers in 
common with it.  
}

\usage{
partialNA(dataset, k=5, NAexp=1, countNAs=FALSE)
}

\arguments{
    \item{dataset}{
        The dataset to process, a data frame or data.table.
    }
    \item{k}{
        The number of tuples to return. These will be the \code{k} most
        frequent tuples, unless \code{k} is negative, in which case the
        least-frequent tuples will be returned.  The latter is useful
        for hunting for outliers.
        
    }
}

\author{
Norm Matloff <matloff@cs.ucdavis.edu>, Harrison Nguyen <hhnguy@ucdavis.edu>, and Vincent Yang <vinyang@ucdavis.edu>
}

\details{
This is the workhorse function in the package, calculating frequency
counts to be used in the graphs.

The data will be converted into a data.table if it is not already in
that form.  For this and other reasons, it is advantageous to have the
data in that form to begin with, say by using \code{fread} to read the
data.

Optionally, tuples that partially match a full tuple pattern except for NA
values will add a partial count to the frequency count for the full
pattern.  If for instance the data consist of 8-tuples and a row in the
data matches a given 8-tuple pattern in 7 of 8 components, this row
would add a count of 7/8 to the frequency for that pattern.  To reduce
this weight, use a value greater than 1.0 for \code{NAexp}.  If that
value is 2, for example, the 7/8 increment will be 7/8 squared.
}

\examples{

  md <- 
     rbind(c(1,2,8),c(1,3,4),c(1,2,8),c(5,NA,NA),c(5,6,2),c(5,NA,NA),c(NA,6,2))
  partialNA(md)
  partialNA(md,countNAs=TRUE)
  data(smallexample)
  partial <- partialNA(smallexample)  
  partial
}
