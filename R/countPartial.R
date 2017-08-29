

###########################  tupleFreqs  ################################

# tupleFreqs():

# finds the frequencies, counting NAs according to formiula

# parameters:

#   dataset: input data frame or data.table
#   k: number of most-frequent patterns to return; if k < 0, return the
#      least-frequent patterns
#   NAexp: weighting factor
#   countNAs: if TRUE, count NA values in a partial weighting
#   saveCounts: if TRUE, save the output to a file 'tupleCounts'
#   minFreq: if non-null, exclude tuples having a frequency below this value
#   accentuate: if non-null, weight specified tuples more heavily
#   accval: weighting factor in that case

# return value:

#  data frame of subclass 'pna', one row per pattern in the data
#  variables, with weighted frequencies

# example:

#  > md
#     V1 V2 V3
#  1:  1  2  8
#  2:  1  3  4
#  3:  1  2  8
#  4:  5  6  2
#  5:  5 NA NA
#  6:  5 NA NA
#  7: NA  6  2
#  > tupleFreqs(md,2,countNAs=TRUE)
#    V1 V2 V3     freq
#  3  5  6  2 2.333333
#  1  1  2  8 2.000000

# the tuple (1,2,8) appears twice in the input data, thus has a
# frequency of 2; but (5,NA,NA) appears twice, and it is assumed that it
# might be a match to (5,6,2), if only the NA values were known, so we
# count them 1/3 each, and similarly count (NA,6,2) as a 2/3 match, for
# a total of 1 + 2*(2/3) + 2/3 = 2 1/3; but if there were a pattern
# (5,1,2), it would NOT count as a partial match to (5,6,2)

# the argument NAexp is used to reduce the weights of partial matches;
# in the above example, if NAexp = 2, then the 2/3 figure becomes (2/3)^2

tupleFreqs = function (dataset, 
                      k = 5, NAexp = 1.0,countNAs=FALSE,saveCounts=TRUE, 
                      minFreq=NULL,accentuate=NULL,accval=100) {
    if (class(dataset)[1] == 'pna')
        stop('does not yet allow preprocessed data')

    if (sum(complete.cases(dataset)) == 0){
        stop('Cannot process datasets without any complete rows.')
    }

    original_categorycol = attr(dataset, "categorycol")
    original_categoryorder = attr(dataset, "categoryorder")

    # data.table package very good for tabulating counts
    if (!data.table::is.data.table(dataset)) 
       dataset <- data.table::as.data.table(dataset)
    attr(dataset, "categorycol") <- original_categorycol
    attr(dataset, "categoryorder") <- original_categoryorder

    # somehow NAs really slow things down

    nonNArows <- which(complete.cases(dataset))
    counts <- dataset[nonNArows,.N,names(dataset)]
    counts <- as.data.frame(counts)
    names(counts)[ncol(counts)] <- 'freq'
    dimensions = dim(counts)
    freqcol = ncol(counts)  # column number of 'freq'
    freqcol1 <- freqcol - 1  # number of data cols

    if (countNAs) {
        # go through every NA row and every non-NA row; whenever the NA
        # row matches the non-NA row in the non-NA values, add to the
        # frequency of the non-NA row
        partialMatch <- function(nonNArow) all(aNonNAs == nonNArow[nonNAcols])
        NArows <- setdiff(1:nrow(dataset),nonNArows)
        dsNA <- as.data.frame(dataset[NArows,])
        for (a in 1:nrow(dsNA)) {
            aRow <- dsNA[a,]
            if (all(is.na(aRow))) {
                next
            }
            nonNAcols <- which(!is.na(aRow))
            aNonNAs <- aRow[nonNAcols]
            tmp <- apply(counts,1,partialMatch)
            wherePartMatch <- which(tmp)
            freqincrem <- (length(nonNAcols) / freqcol1)^NAexp
            counts[wherePartMatch,freqcol] <-
                counts[wherePartMatch,freqcol] + freqincrem
        }
    }

    if (!is.null(accentuate)) {
        cmd <- paste("tmp <- which(",accentuate,")",sep='')
        docmd(cmd)
        counts[tmp,]$freq <- accval * counts[tmp,]$freq
    }

    # get k most/least-frequent rows
    k = min(k, nrow(counts))
    ordering <- order(counts$freq,decreasing=(k > 0))
    counts <- counts[ordering[1:abs(k)],]

    for(i in 1:freqcol){
        if(is.numeric(counts[[i]])){
            next
        } else {
            counts[[i]] <- factor(counts[[i]])
        }
    }

    # Save attributes and their orders for drawing
    if (!is.null(attr(dataset, "categorycol"))) {
        attr(counts, "categorycol") <- attr(dataset, "categorycol")
        attr(counts, "categoryorder") <- attr(dataset, "categoryorder")
    }

    if (!is.null(minFreq)) {
        counts <- counts[counts$freq >= minFreq,]
    }

    class(counts) <- c('pna','data.frame')
    attr(counts,'k') <- k
    attr(counts,'minFreq') <- minFreq

    if (saveCounts) save(counts,file='tupleCounts')

    return(counts)
}

###########################  clsTupleFreqs  ################################

clsTupleFreqs <- function (cls=NULL, dataset, k = 5, NAexp = 1.0,countNAs=FALSE) {
    if (class(dataset)[1] == 'pna') {
        stop('does not yet allow preprocessed data')
    }

    # Save categories for after potential dataset conversion to data.table
    original_categorycol <- attr(dataset, "categorycol")
    original_categoryorder <- attr(dataset, "categoryorder")

    # data.table package very good for tabulating counts
    if (!data.table::is.data.table(dataset)) 
       dataset <- data.table::as.data.table(dataset)
    attr(dataset, "categorycol") <- original_categorycol
    attr(dataset, "categoryorder") <- original_categoryorder

    # This part sets the base table for non-NA rows
    nonNArows <- which(complete.cases(dataset))
    counts <- dataset[nonNArows,.N,names(dataset)]
    counts <- as.data.frame(counts)

    if (nrow(counts) == 0) {
        stop("Must have at least one full row.")
    }

    names(counts)[ncol(counts)] <- 'freq'
    dimensions <- dim(counts)
    freqcol <- ncol(counts)   # column number of 'freq'
    freqcol1 <- freqcol - 1  # number of data cols

    # Make a data frame of just rows with NA's
    na_counts <- as.data.frame(dataset[!nonNArows,.N,names(dataset)])

    if (countNAs) {
        # Don't take all cores because we need to leave one open for main usage
        madeCluster <- FALSE
        if (!cls) {
            numCores <- detectCores()
            cls <- makeCluster(numCores)
            madeCluster <- TRUE
        }

        # Split our na dataframe amongst each core
        distribsplit(cls, 'na_counts')

        # This function takes each subset of the na dataframe
        # and adds corresponding frequencies to the "full row" column.
        minipna <- function(df, counts, NAexp = 1.0){
            partialMatch<- function(nonNArow)
                all(aNonNAs == nonNArow[nonNAcols])

            NArows <- setdiff(1:nrow(dataset),nonNArows)

            # For each row of our subset, add the NA frequency portions
            for (a in 1:nrow(df)) {
                aRow <- df[a,]
                if (all(is.na(aRow))) {
                    next
                }
                nonNAcols <- which(!is.na(aRow))
                aNonNAs <- aRow[nonNAcols]
                tmp <- apply(counts,1,partialMatch)
                wherePartMatch <- which(tmp)
                freqincrem <- (length(nonNAcols) / freqcol1)^NAexp
                counts[wherePartMatch,freqcol] <-
                    counts[wherePartMatch,freqcol] + freqincrem
            }

            return(counts)
        }
        # Save original frequencies
        original_freq <- counts$freq

        # Zero frequencies so we only have to account for the partial
        # frequencies after cluster processing
        counts$freq <- 0
        clusterExport(cls, 
                      varlist=c("minipna", "counts", "NAexp"), envir=environment())
        r <- clusterEvalQ(cls, minipna(na_counts, counts, NAexp))
        counts$freq = original_freq

        for(clusterNum in 1:length(r)){
            counts$freq = 
                as.numeric(counts$freq) + as.numeric(r[[clusterNum]]$freq)
        }

        if (madeCluster){
            stopCluster(cls)
        }
    }

    # get k most/least-frequent rows
    k <- min(k, nrow(counts))
    ordering <- order(counts$freq,decreasing=(k > 0))
    counts <- counts[ordering[1:abs(k)],]

    for(i in 1:freqcol) {
        if(is.numeric(counts[[i]])) {
            next
        } else {
            counts[[i]] <- factor(counts[[i]])
        }
    }

    # Save attributes and their orders for drawing
    if (!is.null(attr(dataset, "categorycol"))) {
        attr(counts, "categorycol") <- attr(dataset, "categorycol")
        attr(counts, "categoryorder") <- attr(dataset, "categoryorder")
    }

    class(counts) <- c('pna','data.frame')
    attr(counts,'k') <- k

    return(counts)
}

