\name{freqparcoord.cd}
\alias{freqparcoord.cd}
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
    discparcoord(data, k = NULL, grpcategory = NULL, permute = FALSE, interactive = FALSE, save=FALSE, name="Parcoords", labelsOff=TRUE)
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
        Whether or not you want to use interactive plotting. 
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
Norm Matloff <matloff@cs.ucdavis.edu>, Harrison Nguyen <hhnguy@ucdavis.edu>, and Vincent Yang <vinyang@ucdavis.edu>
}

\examples{
    file <- system.file("data", "hrdata.csv", package="freqparcoord.cd")
    hrdata = read.table(file, header=TRUE, sep=",", na.strings="")
    input1 = list("name" = "average_montly_hours", "partitions" = 3, "labels" = c("low", "med", "high"))
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
