\name{quickstart}
\alias{quickstart}

\title{
    cdparcoord: Quick start
}

\examples{
    data(hrdata)
    input1 = list("name" = "average_montly_hours",
                  "partitions" = 3, "labels" = c("low", "med", "high"))
    input = list(input1)
    # this will discretize the data by partitioning average monthly 
    # hours into 3 parts called low, med, and high
    hrdata = discretize(hrdata, input)
    # account for NA values and plot with parallel coordinates
    discparcoord(hrdata)

    # same as above, but with scrambled columns
    discparcoord(hrdata, permute=TRUE)

    # same as above, but show top k values
    discparcoord(hrdata, k=8)

    # same as above, but group according to profession
    discparcoord(hrdata, grpcategory="sales")
}

