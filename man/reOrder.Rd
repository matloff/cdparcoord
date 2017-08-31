\name{reOrder} 
\alias{reOrder}    

\title{
    Re-order levels of a factor, according to some desired ordinal form.
}

\description{
    Use to order the levels of a factor in a desired sequence.
}

\usage{
    reOrder(dataset, colName, levelNames)
}

\arguments{
    \item{dataset}{
        Dataset to reorder.
    }
    \item{colName}{
        Column name.
    }
    \item{levelNames}{
        Names of the reordered levels
    }
}

\examples{
   sl <- c('primary','college','hs','middle','hs')
   z <- data.frame(
          schlvl = factor(x=sl,
             levels=c('college','hs','middle','primary'))
          )
   z
   z <- reOrder(z,'schlvl',c('primary','middle','hs','college'))
   str(z)  # shows the desired label order in the 'categoryorder' attribute
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}
