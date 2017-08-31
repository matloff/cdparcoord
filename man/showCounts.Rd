\name{showCounts} 
\alias{showCounts}    

\title{
    Show tuple counts for the most recent saved counting operation.
}

\description{
    Used with \code{saveCounts=TRUE} in \code{tupleFreqs} etc.
    to recover the tuple counts.
}

\usage{
    showCounts(nshow=NULL)
}

\arguments{
    \item{nshow}{
        Dataset to show.
    }
}

\examples{
   data(smallexample)
   z <- tupleFreqs(smallexample)
   z
   showCounts()  # not too useful in this case
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}
