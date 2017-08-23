\name{makeFactor} 
\alias{makeFactor}    

\title{
    Change numeric variables, specified in varnames, in df to factors.
}

\description{
    Change numeric variables that are specified in varnames in a dataframe
    to factors so that discretize won't take partition levels.
}

\usage{
    makeFactor(df, varnames)
}

\arguments{
    \item{df}{
        The data frame to alter to have factors.
    }
    \item{varnames}{
        Variable names for factors.
    }
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}
