\name{makeFactor} 
\alias{makeFactor}    

\title{
    Change numeric variables factors.
}

\description{
    Change numeric variables that are specified in \code{varnames}
    to factors so that \code{discretize} won't partition. 
}

\usage{
    makeFactor(df, varnames)
}

\arguments{
    \item{df}{
        Input data frame.
    }
    \item{varnames}{
        Names of variables to be converted to factors.
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}
