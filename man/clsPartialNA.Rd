\name{clsTupleFreqs}
\alias{tupleFreqs}
\alias{clsTupleFreqs}
\alias{discparcoord}


\title{
    Compute/display tuple frequency counts, and optionally account for 
    NA values
}

\usage{
    tupleFreqs(dataset,k=5,NAexp=1.0,countNAs=FALSE,saveCounts=TRUE, 
       minFreq=NULL,accentuate=NULL,accval=100) 
    clsTupleFreqs(cls=NULL, dataset, k=5, NAexp=1, countNAs=FALSE)
    discparcoord(data, k=5, grpcategory=NULL, permute=FALSE,
        interactive = TRUE, save=FALSE, name="Parcoords", labelsOff=TRUE,
        NAexp=1.0,countNAs=FALSE, accentuate=NULL, accval=100, inParallel=FALSE,
        cls=NULL, differentiate=FALSE, saveCounts=TRUE, minFreq=NULL)
}

\description{
    The functions \code{tupleFreqs} and \code{discparcoord} are
    the workhorse functions in the 
    package, calculating frequency counts to be used in the graphs and
    displaying them. 
}

\arguments{
    \item{data}{
        The data, in data frame or matrix form.
    }
    \item{k}{
        The number of tuples to return. These will be the \code{k} most
        frequent tuples, unless \code{k} is negative, in which case the
        least-frequent tuples will be returned.  The latter is useful
        for hunting for outliers.
    }
    \item{grpcategory}{
        Grouping column/variable.
    }
    \item{permute}{
        If TRUE, randomly permute the columns before plotting.
    }
    \item{interactive}{
        If TRUE, use interactive plotting, allowing for interactively
        readjusting column order and scrubbing/brushing. 
    }
    \item{save}{
        If this is TRUE and interactive mode is on, saved plot
        will be available from the browser.
    }
    \item{name}{
        The name for the plot.
    }
    \item{labelsOff}{
        If TRUE, labels are off. This only comes into
        effect when interactive=FALSE.
    }
    \item{NAexp}{
        Scale for NA counts.
    }
    \item{countNAs}{
        If TRUE, count NA values.
    }
    \item{accentuate}{
        Character expression specifying the property to accentuate.
    }
    \item{accval}{
        Value to accentuate. 
    }
    \item{inParallel}{
        If TRUE, calculate tuple frequencies in parallel. 
    }
    \item{differentiate}{
       If TRUE, randomize coloring to differentiate overlapping
       lines. 
    }
    \item{saveCounts}{
        If TRUE, save the tuple counts to the file \file{tupleCounts}.
    }
    \item{minFreq}{
        The smallest frequency to be displayed.
    }
    \item{dataset}{
        The dataset to process, a data frame or data.table.
    }
    \item{cls}{
        Cluster to be used if \code{inParallel} is TRUE.  If
        \code{inParallel} is TRUE and \code{cls} is not supplied, 
        it will use the sensed number of cores on the calling machine 
        by default. 
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, 
    and Harrison Nguyen <hhnguy@ucdavis.edu>
}

\details{
    Tuple tabulation is performed by \code{tupleFreqs}, or in large
    cases, in parallel by \code{clsTupleFreqs}.  The display is done by
    \code{discparcoord}.

    The \code{k} most- or least-frequent tuples will be reported, 
    with the latter specified via negative \code{k}.  Optionally, 
    tuples with NA values will count less, but weigh toward 
    everything that has existing numbers in common with it.  

    If continuous variables are present, then in most cases, either
    convert to discrete using \code{\link{discretize}} or use
    \pkg{freqparcoord}.

    The data will be converted into a data.table if it is not already in
    that form.  For this and other reasons, it is advantageous to have the
    data in that form to begin with, say by using \code{data.table::fread} 
    to read the data.

    Optionally, tuples that partially match a full tuple pattern except for NA
    values will add a partial count to the frequency count for the full
    pattern.  If for instance the data consist of 8-tuples and a row in the
    data matches a given 8-tuple pattern in 7 of 8 components, this row
    would add a count of 7/8 to the frequency for that pattern.  To reduce
    this weight, use a value greater than 1.0 for \code{NAexp}.  If that
    value is 2, for example, the 7/8 increment will be 7/8 squared.
}

\value{
    The functions \code{tupleFreqs} and \code{clsTupleFreqs} return an
    object of class \code{c('pna','data.frame')}, with each row
    consisting of a tuple and its count.  In addition the object will
    have attributes \code{k} and \code{minFreq}.

    The function \code{discparcoord} returns an object of class
    \code{c('plotly','htmlwidget')}.  Printing the object causes display
    of the graph.
}

\examples{

   \dontrun{
       data(Titanic)
       # Find frequencies in parallel
       discparcoord(Titanic, inParallel=TRUE)
    }

    data(hrdata)
    input1 = list("name" = "average_montly_hours",
                  "partitions" = 3, "labels" = c("low", "med", "high"))
    input = list(input1)
    # this will discretize the data by partitioning average monthly 
    # hours into 3 parts called low, med, and high
    hrdata = discretize(hrdata, input)
    print('first few discretized tuples')
    # first line should be 0.38,0.53,2,low,3,0,1,00,sales,low
    head(hrdata)
    print('first few most-frequent tuples')
    # first line should be 0.40,0.46,2,...,11
    tupleFreqs(hrdata)
    unlink('tupleCounts')
    \dontrun{
       # account for NA values and plot with parallel coordinates
       discparcoord(hrdata)
       # same as above, but with scrambled columns
       discparcoord(hrdata, permute=TRUE)
       # same as above, but show top k values
       discparcoord(hrdata, k=8)
       # same as above, but group according to profession
       discparcoord(hrdata, grpcategory="sales")
    }
}

