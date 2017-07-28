\name{cdparcoord}
\alias{cdparcoord}
\alias{discparcoord}

\title{
    Parallel coordinates.
}

\description{
    A novel approach to the parallel coordinates method for visualization multiple
    variables at once, focused on discrete variables.

    (a) Addresses the screen-clutter problem in parallel coordinates, by
    only plotting the "most typical" cases. These are the tuples with the highest
    occurance and representation with potentially occuring NA values.

    (b) Provides a novel approach to NA values by allowing tuples with NA values
    to partially contribute to complete tuples rather than eliminating or
    predicting missing values.

    (c) Allows for randomization such that the user may rearrange columns to
    find hidden relationships between variables.
}

\usage{
    discparcoord(data, k=5, grpcategory=NULL, permute=FALSE,
                 interactive = TRUE, save=FALSE, name="Parcoords", labelsOff=TRUE,
                 NAexp=1.0,countNAs=FALSE, accentuate=NULL, accval=100, inParallel=FALSE,
                 cls=NULL, differentiate=FALSE)
}

\arguments{
    \item{data}{
        The data, in data frame or matrix form.
    }
    \item{k}{
        The number of lines to display in the parallel coordinates plot.
    }
    \item{grpcategory}{
        The name of the column and variable that you want to partition graphs into.
    }
    \item{permute}{
        Whether or not you want to permute the columns before drawing.
    }
    \item{interactive}{
        Whether or not you want to use interactive plotting. If this is true, then
        Plotly will be used for interactive plotting. This allows for interactively
        readjusting column order and scrubbing.
        If this is false, then this will use basic plotting that generates an image
        or saves a png to the current directory.
        By default, interactive = TRUE
    }
    \item{save}{
        Whether or not you want to save the plot. If interactive mode is on, save
        will be available from the browser.
    }
    \item{name}{
        The name for the plot (default is Parcoords).
    }
    \item{labelsOff}{
        Whether or not labels are off. By default, they are off. This only comes into
        effect when interactive=FALSE.
    }
    \item{NAexp}{
        Scale NA signifiance.
    }
    \item{countNAs}{
        Whether or not you want to count NA values.
    }
    \item{accentuate}{
        The property you want to accentuate.
    }
    \item{accval}{
        The value to accentuate. By default, this is 100.
    }
    \item{inParallel}{
        Whether or not you want to calculate tuple frequencies in parallel. Default is false.
    }
    \item{cls}{
        The cluster of cores you'd like to use for computing frequencies in parallel. If
        isParallel is TRUE and this is not supplied, it will use numCores by default.
    }
    \item{differentiate}{
       Whether or not you want to randomize coloring to differentiate overlapping
       lines. By default, this is FALSE.
    }
}

\details{
    Parallel coordinates allow the user to see the relationships between
    many different variables on the same graph. It can be thought of as a scatter graph that
    extends behond just two variables. For example, if we had three variables Height, Weight
    and Age, each variable would have its own vertical axis. Each point then "connects the dots"
    on the vertical axes. in this case, (70, 160, 28) would be a segmented line that has 70 on the
    Height axis, 160 on the Weight axis, and 28 on the Age axis. An example of this is parcoord,
    found in the MASS package.

    One of the issues with parallel coordinates is that if there are too many lines, the screen will
    be cluttered, hence "black screen problem". The package this extends, freqparcoord, addresses this
    for continuous variables; discparcoord fixes this problem when dealing with discrete variables by
    plotting only the most occuring tuples (user specified amount).

    The other problem that discparcoord addresses is the occurrence of NA values in dataset.
    Usually, there are two solutions to this problem: either ignore the entire tuple,
    or use various models to predict what the values would be based on all the other data (imputation). Instead
    of using either of these, we take partial values of incomplete tuples and then add those values to complete
    matching tuples. For example, given a tuple (1, 2, NA) and (1, 2, 3), the final count of tuples
    would be (1, 2, 3), occurring 1.66 times. The incomplete tuple is only counted for 2/3.
}

\value{
    Object of type "graph".
}

\author{
    Norm Matloff <matloff@cs.ucdavis.edu>, Vincent Yang <vinyang@ucdavis.edu>, and Harrison Nguyen <hhnguy@ucdavis.edu>
}

\examples{
    data(hrdata)
    input1 = list("name" = "average_montly_hours",
                  "partitions" = 3, "labels" = c("low", "med", "high"))
    input = list(input1)
    # This will discretize the data by partitioning average monthly hours into 3 parts
    # called low, med, and high
    hrdata = discretize(hrdata, input)
    # account for NA values and plot with parallel coordinates
    discparcoord(hrdata)

    # same as above, but with scrambled columns
    discparcoord(hrdata, permute=TRUE)

    # same as above, but show top k values
    discparcoord(hrdata, k=8)

    # same as above, but group according to profession
    discparcoord(hrdata, grpcategory="sales")

    # same as above, but with an interactive plot
    discparcoord(hrdata, interactive=TRUE)
}
