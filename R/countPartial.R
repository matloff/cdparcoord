library(plyr)

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

discretize = function (dataset, input){
    for(col in input){
        # read all the input into local variables
        name = col[['name']]
        partitions = col[['partitions']]
        labels = col[['labels']]
        colMax = max(dataset[name])
        colMin = min(dataset[name])
        range = colMax - colMin
        increments = range/partitions

        tempLower = colMin
        tempUpper = 0

        # go through each and replace values according to partitions
        for(i in 1:partitions){
            tempUpper = tempLower + increments
            dataset[[name]][dataset[[name]] <= tempUpper] <- labels[i]
            tempLower = tempUpper
        }

    }

    return(dataset)

}

# currently counts all partials and adds them properly
# parameters:
#   dataset (table): dataset to calculate partials for
#   n (int): how many top rows to return (DEFAULT = 5)
partialNA = function (dataset, n){
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
            count[i, columns] = count[i, columns] * (((columns - 1) - sum(is.na(count[i, ]))) / as.numeric(columns - 1))
            NAValues = c(NAValues, i)
        }
    }

    # go through every NA row and if they match, add partials to complete frequencies
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
    if (!missing(n)){
        count <- head(count[order(-count$freq),], n)
    } else {
        count <- head(count[order(-count$freq),], 5)
    }

    for(i in 1:columns){
        if(is.numeric(count[, i])){
            next
        } else {
            count[[i]] <- factor(count[[i]])
        }
    }

    return(count)
}


# output parallel coordinates plot as Rplots.pdf
# name: name for plot
draw = function(partial, name, labelsOff) {

    width <- ncol(partial)-1
    # get only numbers
    nums <- Filter(is.numeric, partial)
    max_y <- max(nums[(1:nrow(nums)),1:(ncol(nums) - 1)]) # option 1
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
    if (!missing(name)){
        png(name)
    }
    layout(matrix(1:2,ncol=2), width = c(2,1),height = c(1,1))
    plot(baserow,type="n", ylim = range(0, max_y), xaxt="n",yaxt="n", xlab="",ylab="", frame.plot=FALSE)

    # Add aesthetic
    title(main="Parallel Coordinates", col.main="black", font.main=4)
    axis(1, at=1:width, lab=head(colnames(partial), -1))
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
        fr <- partial[i, width+1] / scale # determine thickness via frequency

        lines(row, type='o', col=colfunc(max_freq)[round(fr/scale, digits=0)], lwd=fr) # add plot lines

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
    plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', main = 'Frequency %')
    text(x=1.5, y = seq(0, 1, l=5), labels = seq(1,0,l=5))
    rasterImage(legend_image, 0, 0, 1, 1)
}

# requires GGally
interactivedraw <- function(partial, name="Parallel", labelsOff) {

    library(plotly)
    # Initialize API keys for plotly
    Sys.setenv("plotly_username"="aeonneo")
    Sys.setenv("plotly_api_key"="VVnKOIU2ZJcwq0t7CIqg")

    # create list of lists of lines
    interactiveList <- list()
    categ <- list()

    # Map unique categorical variables to numbers
    for(col in 1:(ncol(partial)-1)){
        # Store the columns that have categorical variables
        categ[[col]] <- c(levels(partial[, col]))

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

    # find the max value and the max frequency
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
            interactiveList[[i]] <-
                list(range = c(1,max_y), 
                constraintrange = c(1,max_y),
                label = colnames(partial)[i],
                values = unlist(partial[,i]),
                tickvals = 1:length(categ[[i]]),
                ticktext = categ[[i]]
                )
        }
        else {
            interactiveList[[i]] <-
                list(range = c(1,max_y), 
                constraintrange = c(1,max_y),
                label = colnames(partial)[i],
                values = unlist(partial[,i]))
        }

    }

    # Convert partial to plot
    colfunc <- colorRampPalette(c("red", "yellow", "springgreen", "royalblue"))
    p <- partial %>%
        plot_ly(type = 'parcoords', 
                line = list(color = ~freq,
                            colorscale = 'Jet',
                            showscale = TRUE,
                            reversescale = TRUE,
                            cmin = min_freq,
                            cmax = max_freq),
                dimensions = interactiveList
                )

    p
    # Create plot
    #chart_link = api_create(p, filename=name)
    #chart_link
}

interactexample <- function() {
    df <- read.csv("freqparcoord.cd/data/parcoords_data.csv")
    df
    library(plotly)

    #df <- read.csv("https://raw.githubusercontent.com/bcdunbar/datasets/master/parcoords_data.csv")

    p <- df %>%
        plot_ly(width = 1000, height = 600) %>%
        add_trace(type = 'parcoords',
                  line = list(color = ~colorVal,
                              colorscale = 'Jet',
                              showscale = TRUE,
                              reversescale = TRUE,
                              cmin = -4000,
                              cmax = -100),
                  dimensions = list(
                                    list(range = c(~min(blockHeight),~max(blockHeight)),
                                         constraintrange = c(100000,150000),
                                         label = 'Block Height', values = ~blockHeight),
                                    list(range = c(~min(blockWidth),~max(blockWidth)),
                                         label = 'Block Width', values = ~blockWidth),
                                    list(tickvals = c(0,0.5,1,2,3),
                                         ticktext = c('A','AB','B','Y','Z'),
                                         label = 'Cyclinder Material', values = ~cycMaterial),
                                    list(range = c(-1,4),
                                         tickvals = c(0,1,2,3),
                                         label = 'Block Material', values = ~blockMaterial),
                                    list(range = c(~min(totalWeight),~max(totalWeight)),
                                         visible = TRUE,
                                         label = 'Total Weight', values = ~totalWeight),
                                    list(range = c(~min(assemblyPW),~max(assemblyPW)),
                                         label = 'Assembly Penalty Weight', values = ~assemblyPW),
                                    list(range = c(~min(HstW),~max(HstW)),
                                         label = 'Height st Width', values = ~HstW),
                                    list(range = c(~min(minHW),~max(minHW)),
                                         label = 'Min Height Width', values = ~minHW),
                                    list(range = c(~min(minWD),~max(minWD)),
                                         label = 'Min Width Diameter', values = ~minWD),
                                    list(range = c(~min(rfBlock),~max(rfBlock)),
                                         label = 'RF Block', values = ~rfBlock)
                                    )
                  )


        # Create a shareable link to your chart
        # Set up API credentials: https://plot.ly/r/getting-started
        #chart_link = api_create(p)
        #chart_link
        p
}

smallexample <- function(n, categ) {
    #file <- system.file("data", "smallexample.csv", package="freqparcoord.cd")
    file <- system.file("data", "categoricalexample.csv", package="freqparcoord.cd")
    dataset = read.table(file, header=TRUE, sep=";", na.strings="")

    # select top n frequencies
    if (missing(n)){
        partial <- partialNA(dataset)  
    }
    else {
        partial <- partialNA(dataset, n)
    }
    print(partial)
    #draw(partial)
    interactivedraw(partial)
}

# this is the main graphing function - use this
# data should be input as a dataframe
# need to figure out how to DISCRETIZE COLUMNS 
# 1. permute columns
# 2. interactive columns
# 3. figure out labeling program
# 4. Need to add in a way to choose which names to label pdfs with
discparcoord <- function(data, k = NULL, grpcategory = NULL, permute = FALSE){

    # check to see if column name is valid
    if(!(grpcategory %in% colnames(data)) && !(is.null(grpcategory))){
        stop("Invalid column names")
        # check to see if grpcategory given
    } else if (is.null(grpcategory)){
        # get top k or default to five
        par(mfrow=c(1,1))
        if(is.null(k)){
            partial <- partialNA(data, 5)
        } else {
            partial <- partialNA(data, k)
        }

        # to permute or not to permute
        if(permute){
            partial = partial[,c(sample(ncol(partial)-1), ncol(partial))]
        }

        draw(partial)
        # grpcategory is given and is valid
    } else {
        lvls = levels(data[[grpcategory]])
        par(mfrow=c(2,1)) 
        for(i in 1:length(lvls)){
            cat = lvls[i]
            graph = data[which(data[[grpcategory]] == cat), ]
            data = data[, !(colnames(data) %in% c(grpcategory))]
            if(is.null(k)){
                partial <- partialNA(data, 5)
            } else {
                partial <- partialNA(data, k)
            }

            if(permute){
                partial = partial[,c(sample(ncol(partial)-1), ncol(partial))]
            }
            draw(partial)
        }
    }
}
