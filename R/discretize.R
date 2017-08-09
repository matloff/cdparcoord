


###########################  discretize  ################################

# discretizes certain columns of the input dataset, either those
# specified by the caller, or if no specification, (almost) all numeric
# columns

# arguments:

#   dataset: data frame that holds the data
#   input: list of lists, where each list is used to represent a column; 
#       the inner list should contain the following vars:
#         1. partitions (int) - number of partitions to make
#         2. labels (vector of strs) - OPTIONAL -what to label the
#            partitions. if none, default is just to have ints as labels
#         3. lower bounds (vector) - OPTIONAL - lower cutoffs for each label
#         4. upper bounds (vector) - Optional - upper cutoffs for each label

# value:
#
#    discretized data frame

# example:
# cat1 =
#    list('name' = 'cat1', 'partitions' = 3, 'labels' = c('low', 'med', 'high'))
# cat2 =
#    list('name' = 'cat2', 'partitions' = 2, 'labels' = c('yes', 'no'))
# input = list(cat1, cat2)

discretize <- function (dataset, input=NULL, ndigs=2, nlevels=10) {
    # general plan: replace numerical data column by character strings,
    # which will be used in the counts and serve as the labels for 
    # the tick marks
    if (is.null(input)) {
        input <- list()
        for (nm in names(dataset)) {
            dscol <- dataset[[nm]]
            inp <- list()
            if (!is.numeric(dscol) || length(table(dscol)) <= nlevels) {
                inp[['dontchange']] <- TRUE
                unqdscol <- unique(dscol)
                inp[['partitions']] <- length(unqdscol)
                inp[['labels']] <- as.character(unqdscol)
            } else {
                inp[['name']] <- nm
                inp[['partitions']] <- nlevels
                dscolr <- rank(dscol)
                nr <- nrow(dataset)
                incr <- nr / nlevels
                # get left endpoints of the subintervals of (1,2,...,nr)
                tmp <- seq(1,nr,incr)
                lefteps <- round(tmp)  
                # get corresponding values of dscol 
                dscols <- sort(dscol)
                lvls <- dscols[lefteps]
                # these will then be our labels
                lbls <- format(lvls,digits=ndigs)
                inp[['labels']] <- lbls
                # "round off" our data accordingly; convert from the old
                # ranks to the new ones in the discretized data
                tmp <- round(dscolr / incr) + 1
                tmp <- pmin(tmp,nlevels)
                dataset[[nm]] <- lbls[tmp]
                inp[['dontchange']] <- FALSE
            }
            input[[nm]] <- inp
        }
    } else {  # end null input, start non-null
        for(col in input) {
            if (!is.null(col$dontchange) && col$dontchange) next
            # read all the input into local variables
            name = col[['name']]
            partitions = col[['partitions']]
    
            # It is possible that a column has already been converted.
            # If so, it will have non-numeric characters. Alternately,
            # if it already has non-numeric characters, then it
            # should not be considered for discretizing
            if (!is.numeric(dataset[[name]])) {
                next
            }
    
            colMax = max(dataset[name], na.rm = TRUE)
            colMin = min(dataset[name], na.rm = TRUE)
            range = colMax - colMin
            increments = range/partitions
    
            tempLower = colMin
            tempUpper = 0
    
            thisColData <- dataset[name][,1]
            lvls <- round((thisColData - colMin) / increments)
            lvls <- pmax(lvls,1)
            lvls <- pmin(lvls,partitions)
            labels = col[['labels']]
    
            dataset[[name]] <- labels[lvls]
        }
    }

    labelcol <- list()
    labelorder <- list()
    for(i in 1:length(input)) {
        labelcol[[i]] <- unique(input[[i]]$name)
        labelorder[[i]] <- unique(input[[i]]$labels)
    }

    # Save the categories and their orders
    attr(dataset, "categorycol") <- c(attr(dataset, "categorycol"), labelcol)
    attr(dataset, "categoryorder") <- c(attr(dataset,
                                             "categoryorder"), labelorder)

    return(dataset)
}

###########################  reOrder  ################################

# wrapper for discretize(); use to order the levels of a factor in a
# desired sequence
reOrder <- function(dataset,colName,levelNames) {
    inputlist <- list()
    inputlist$name <- colName
    inputlist$partitions<- length(levelNames)
    inputlist$labels<- levelNames
    discretize(dataset,list(inputlist))
}

###########################  makeFactor  ################################

# utility to change numeric variables, specified in varnames, in df to
# factors, so that discretize() won't make partition levels

makeFactor <- function(df,varnames) {
   for (nm in varnames) {
      df[[nm]] <- as.factor(df[[nm]])
   }
   df
}
