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

\examples{
data(prgeng)
pe <- prgeng[,c(1,3,5,7:9)]
class(pe$educ)  # integer
pe <- makeFactor(pe,c('educ','occ','sex'))
class(pe$educ)  # factor
# nice to give levels names
levels(pe$sex) <- c('male','female')
head(pe$sex)
}

