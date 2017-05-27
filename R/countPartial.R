library(plyr)
library(plotly)

# possible optimization -> add in R code to find the # of columns first


# Used to select a column and discretize
# parameters
#   dataset - dataframe that holds the data
#   list of lists where each list within is used to represent a column -
#       the inner list should contain the following vars:
#         1. partitions (int) - number of partitions to make
#         2. labels (vector of strs) - OPTIONAL -what to label the partitions. if none, 
#                                     default is just to have ints as labels
#         3. lower bounds (vector) - OPTIONAL - lower cutoffs for each label
#         4. upper bounds (vector) - Optional - upper cutoffs for each label
# example:  
# cat1 = list('name' = 'cat1', 'partitions' = 3, 'labels' = c('low', 'med', 'high'))
# cat2 = list('name' = 'cat2', 'partitions' = 2, 'labels' = c('yes', 'no'))
# input = list(cat1, cat2)

discretize <- function (dataset, input){
    for(col in input){
        # read all the input into local variables
        name = col[['name']]
        partitions = col[['partitions']]
        labels = col[['labels']]
        # It is possible that a column has already been converted.
        # If so, it will have non-numeric characters. Alternately,
        # if it already has non-numeric characters, then it
        # should not be considered for discretizing
        if (!is.numeric(dataset[[name]])){
            next
        }
        colMax = max(dataset[name])
        colMin = min(dataset[name])
        range = colMax - colMin
        increments = range/partitions

        tempLower = colMin
        tempUpper = 0

        # Convert the entire column to be characters, because
        # categorical variables are normally strings anyway. 
        # After the first conversion, the entire column will be
        # characters.
        currentCol = as.character(dataset[[name]])

        # go through each and replace values according to partitions
        for(i in 1:partitions){
            tempUpper = tempLower + increments

            # Now that the column has characters, 
            # convert the potentially numerical values to numeric
            # suppress warnings, and allow non-numeric values
            # to become NA, so they don't get changed again
            dataset[[name]][suppressWarnings(as.numeric(dataset[[name]])) <= tempUpper] <- labels[i]
            tempLower = tempUpper
        }

    }

    labelcol = list()
    labelorder = list()
    for(i in 1:length(input)){
        labelcol[[i]] <- input[[i]]$name
        labelorder[[i]] <- input[[i]]$labels
    }

    # Save the categories and their orders
    attr(dataset, "categorycol") <- c(attr(dataset, "categorycol"), labelcol)
    attr(dataset, "categoryorder") <- c(attr(dataset, "categoryorder"), labelorder)


    return(dataset)
}

# currently counts all partials and adds them properly
# parameters:
#   dataset (table): dataset to calculate partials for
#   n (int): how many top rows to return (DEFAULT = 5)
partialNA = function (dataset, k = 5){
    # using plyr library to get a table 
    count = count(dataset, vars = NULL, wt_var = NULL)
    dimensions = dim(count)
    rows = dimensions[1]
    columns = dimensions[2]
    NAValues = c()
    CompleteTuple = c()

    # count up and get the partial values of the NA rows
    for(i in 1:rows){
        if(sum(is.na(count[i, ])) > 0 ) {
            count[i, columns] = count[i, columns] * (((columns - 1) - 
                        sum(is.na(count[i, ]))) / as.numeric(columns - 1))
            NAValues = c(NAValues, i)
        }
    }

    # go through every NA row and if they match, 
    # add partials to complete frequencies
    for(a in NAValues){
        for(i in 1:rows){
            if(i %in% NAValues){
                next
            } else {
                check = count[a,1:columns - 1] == count[i, 1:columns - 1]
                if(!any(check == FALSE, na.rm = TRUE)){
                    count[i, columns] = count[i, columns] + count[a, columns]
                }
            }
        }
    }

    # remove na rows from table
    count <- count[complete.cases(count),]

    # get n highest rows, if no n inputted, default to top five
    count <- head(count[order(-count$freq),], k)

    for(i in 1:columns){
        if(is.numeric(count[, i])){
            next
        } else {
            count[[i]] <- factor(count[[i]])
        }
    }

    if (!is.null(attr(dataset, "categorycol"))){
        attr(count, "categorycol") <- attr(dataset, "categorycol")
        attr(count, "categoryorder") <- attr(dataset, "categoryorder")
    }

    return(count)
}


# output parallel coordinates plot as Rplots.pdf
# name: name for plot
draw <- function(partial, name="Parallel Coordinates", labelsOff, save=FALSE){

    width <- ncol(partial)-1
    # get only numbers
    nums <- Filter(is.numeric, subset(partial,,-c(freq)))
    if (nrow(nums) == 0 || ncol(nums) == 0){
        max_y = 0
    }
    else {
        max_y <- max(nums[(1:nrow(nums)),1:(ncol(nums) - 1)]) # option 1
    }
    max_freq <- max(partial[,ncol(partial)])

    categ <- list()

    # create labels for categorical variables
    # if there is a greater max_y, replace
    for(i in 1:(ncol(partial)-1)){
        categ[[i]] <- c(levels(partial[, i]))
        if (max_y < nlevels(partial[, i])){
            max_y <- nlevels(partial[, i])
        }
    }

    # draw one graph
    # creation of initial plot
    cats = rep(max_y, width)
    baserow = c(1, cats) 
    if (save) {
        png(paste(name, "png", sep=".")) # Save the file instead of displaying
    }

    # Layout left and right sides for the legend
    generateScreen(12, 7)
    layout(matrix(1:2, ncol=2), width = c(2,1), height = c(1,1))
    par(mar=c(9, 4, 4, 2))
    plot(baserow,type="n", ylim = range(0, max_y), 
         xaxt="n", yaxt="n", xlab="", ylab="", frame.plot=FALSE)

    # Add aesthetic
    title(main=name, col.main="black", font.main=4)
    #par(mar=c(5,6,4,1)+.1) # set margins
    par(mar=c(9, 4, 4, 2))
    axis(1, at=seq(2, width, 2), lab=colnames(partial)[seq(2, width, 2)], cex.axis=0.5, las=2)
    axis(1, at=seq(1, width, 2), lab=colnames(partial)[seq(1, width, 2)], cex.axis=0.5, las=2)
    axis(2, at=seq(0,max_y,1))

    # Get scale for lines if large dataset
    if(max_freq > 500){
        scale <- 0.10 * max_freq
    } else {
        scale <- 1
    }

    colfunc <- colorRampPalette(c("red", "yellow", "springgreen", "royalblue"))

    # add on lines
    for(i in 1:nrow(partial)){
        row <- partial[i,1:width]
        row <- as.numeric(row)

        # Scale everything from 0 to 1, then partition into 20 for colors
        fr <- partial[i, width+1] / scale # determine thickness via frequency

        max_freq <- max(partial[,ncol(partial)])
        min_freq <- min(partial[,ncol(partial)])
        fr <- (fr-min_freq)/(max_freq-min_freq)
        fr <- round(fr / (0.05))

        fr <- round(fr)+1
        # Account for if there is only one frequency
        if (!is.finite(fr)) {
            fr = 11
        }

        lines(row, type='o', col=colfunc(21)[fr], 
              lwd=fr) # add plot lines

        if(!missing(labelsOff) && labelsOff == FALSE){
            # add on labels
            for(i in 1:(ncol(partial)-1)){
                # if this column is full of categorical variables
                if (i <= length(categ) && !is.null(categ[[i]])){
                    for(j in 1:length(categ[[i]])){
                        text(i, j, categ[[i]][j])
                    }
                }
            }
        }
    }
    legend_image <- as.raster(matrix(colfunc(20), ncol=1))
    plot(c(0,2),c(0,1),type = 'n', axes = F, 
         xlab = '', ylab = '', main = 'Frequency')
    text(x=1.5, y = seq(0, 1, l=5), labels = seq(round(max_freq),round(min_freq),l=5))
    rasterImage(legend_image, 0, 0, 1, 1)
}

# Accepts a result from partialNA and draws interactively using plotly
# Plots will open in browser and be saveable from there
# requires GGally and plotly
interactivedraw <- function(partial, name="Interactive Parcoords") {
    # How it works:
    # Plotly requires input by columns of values. For example,
    # we would take col1, col2, col3, each of which has 3 values.
    # Then, col1.val1, col2.val1, col3.val1 would make one line. 
    # For categorical variables, we map each unique variable, found
    # with factors, down to a corresponding number. We then substitute
    # this number in the original dataset, then plot it. Finally,
    # we use our mapping from labels to numbers to actually demonstrate
    # which categorical variable represents what. 

    # create list of lists of lines to be inputted for Plotly
    interactiveList <- list()

    # Store categorical variables - categ[[i]] holds the ith column's unique
    # variables. If categ[[i]] is null, that means it is not categorical.
    categ <- list() 

    # Map unique categorical variables to numbers
    for(col in 1:(ncol(partial)-1)){
        # Store the columns that have categorical variables
        
        # Preserve order for categorical variables changed in discretize()
        if (!is.null(attr(partial, "categorycol")) && colnames(partial)[col] %in% attr(partial, "categorycol")){
            # Get the index that the colname is in categorycol
            # categoryorder[index] is the list that you want to assign
            orderedcategories <- attr(partial, "categoryorder")[match(colnames(partial)[col], attr(partial, "categorycol"))][[1]]
            categ[[col]] <- orderedcategories[(orderedcategories %in% c(levels(partial[, col])))]
        }
        # Convert normal categorical variables
        else {
            categ[[col]] <- c(levels(partial[, col]))
        }

        # if this column has categorical variables, change its values
        # to the corresponding numbers accordingly.
        if (col <= length(categ) && !is.null(categ[[col]])){
            for(j in 1:(nrow(partial))){
                tempval <- which(categ[[col]] == partial[j,col])

                # Stop factorizing while we set the value
                partial[[col]] = as.character(partial[[col]])
                partial[j, col] <- tempval

                # After setting the value, reset factors
                partial[[col]] = as.factor(partial[[col]])
            }
            # Stop factorizing now that all values are numbers
            partial[[col]] = as.numeric(partial[[col]])
        }
    }


    # find the max value and the max frequency to set max/min for our plot
    nums <- Filter(is.numeric, partial)
    max_y <- max(nums[(1:nrow(nums)),1:(ncol(nums) - 1)]) # option 1
    max_freq <- max(partial[,ncol(partial)])
    min_freq <- min(partial[,ncol(partial)])

    # update max value for categorical variables, not including freq
    for(i in 1:(ncol(partial)-1)){
        if (max_y < nlevels(partial[, i])){
            max_y <- nlevels(partial[, i])
        }

        # Create list of lists for graphing
        
        # If it is a categorical variable, add ticks and labels
        if (i <= length(categ) && !is.null(categ[[i]])){

            if (length(categ[[i]]) == 1){
                interactiveList[[i]] <-
                    list(range = c(0, 2),
                    label = colnames(partial)[i],
                    values = unlist(partial[,i]),
                    tickvals = 0:2,
                    ticktext = c(" ", categ[[i]][[1]], " ")
                    )
            }
            else {
            interactiveList[[i]] <-
                list(range = c(min(partial[[i]]), max(partial[[i]])),
                constraintrange = c(min(partial[[i]]), max(partial[[i]])),
                label = colnames(partial)[i],
                values = unlist(partial[,i]),
                tickvals = 1:length(categ[[i]]),
                ticktext = categ[[i]]
                )
            }
        }
        # Otherwise, you don't need special ticks/labels
        else {
            interactiveList[[i]] <-
                list(range = c(min(partial[[i]]), max(partial[[i]])),
                    tickformat = '.2f',
                    constraintrange = c(min(partial[[i]]), max(partial[[i]])),
                    label = colnames(partial)[i],
                    values = unlist(partial[,i]))
        }
    }


    # Convert partial to plot
    if (name == ""){
        partial %>%
            plot_ly(type = 'parcoords', 
                    line = list(color = partial$freq,
                                colorscale = 'Jet',
                                showscale = TRUE,
                                reversescale = TRUE,
                                cmin = min_freq,
                                cmax = max_freq),
                    dimensions = interactiveList)
    }
    else {
        plot_ly(partial, type = 'parcoords', 
                line = list(color = partial$freq,
                            colorscale = 'Jet',
                            showscale = TRUE,
                            reversescale = TRUE,
                            cmin = min_freq,
                            cmax = max_freq),
                dimensions = interactiveList
                ) %>%
                layout(title=name)
    }
}

interactcategoricalexample <- function(n, categ) {
    file <- system.file("data", "categoricalexample.csv", 
                        package="freqparcoord.cd")
    dataset = read.table(file, header=TRUE, sep=";", na.strings="")

    # select top n frequencies
    if (missing(n)){
        partial <- partialNA(dataset)  
    }
    else {
        partial <- partialNA(dataset, n)
    }
    print(partial)
    interactivedraw(partial)
}

smallexample <- function(n) {
    file <- system.file("data", "smallexample.csv", package="freqparcoord.cd")
    dataset = read.table(file, header=TRUE, sep=";", na.strings="")

    # select top n frequencies
    if (missing(n)){
        partial <- partialNA(dataset)  
    }
    else {
        partial <- partialNA(dataset, n)
    }
    print(partial)
    draw(partial, name="Small Example")
}

# this is the main graphing function - use this
# data should be input as a dataframe
# need to figure out how to DISCRETIZE COLUMNS 
# 1. permute columns
# 2. interactive columns
# 3. figure out labeling program
# 4. Need to add in a way to choose which names to label pdfs with
discparcoord <- function(data, k = NULL, grpcategory = NULL, permute = FALSE, 
                         interactive = FALSE, save=FALSE, name="Parcoords",
                         labelsOff = TRUE){

    # check to see if column name is valid
    if(!(grpcategory %in% colnames(data)) && !(is.null(grpcategory))){
        stop("Invalid column names")
    } 

    # check to see if grpcategory given
    else if (is.null(grpcategory)){
        # get top k or default to five
        if(is.null(k)){
            partial <- partialNA(data, 5)
        } else {
            partial <- partialNA(data, k=k)
        }

        # to permute or not to permute
        if(permute){
            partial = partial[,c(sample(ncol(partial)-1), ncol(partial))]
        }

        if (!interactive){
            draw(partial, name=name, save=save, labelsOff=labelsOff)
        }
        else {
            interactivedraw(partial, name=name)
        }
    } 
    # grpcategory is given and is valid
    else {
        lvls = levels(data[[grpcategory]])

        # generate a list of plots for grpcategory
        plots = list()

        # iterate through each different value in the selected category
        for(i in 1:length(lvls)){
            cat = lvls[i]
            graph = data[which(data[[grpcategory]] == cat), ]
            ctgdata = data[, !(colnames(data) %in% c(grpcategory))]

            if (is.null(k)){
                partial <- partialNA(ctgdata, k=5)
            }
            else {
                partial <- partialNA(ctgdata, k=k)
            }
            if(permute){
                partial = partial[,c(sample(ncol(partial)-1), ncol(partial))]
            }

            if (!interactive){
                # Saving is only an option on noninteractive plotting
                if (save) {
                    draw(partial, name=paste(name, cat), save=save, labelsOff=labelsOff)
                }
                else {
                    generateScreen(12, 7)
                    draw(partial, name=paste(name, cat), labelsOff=labelsOff)
                }
            }
            else {
                numcat <- paste(i, cat)
                fullname <- paste(name, numcat)
                plots[[i]] <- interactivedraw(partial, name=fullname)
            }
        }
        return(plots)
    }
}

# Create a new screen for grpcategory
generateScreen <- function(width, height) {
    # MacOS
    if (grepl("darwin", R.version$os)){
        quartz(width=width, height=height)
    }
    # Linux
    else if (grepl("linux", R.version$os) || grepl("gnu", R.version$os)) {
        X11(width=width, height=height)
    }
    # Windows
    else {
        windows(width=width, height=height)
    }
}
