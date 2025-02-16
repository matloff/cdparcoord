

###########################  draw  ################################


# output parallel coordinates plot as Rplots.pdf
# name: name for plot
draw <- function(partial, name="Parallel Coordinates", labelsOff, save=FALSE,
   colorPalette,sameGraphGrpVar) 
{
        width <- ncol(partial)-1

        # get only numbers
        nums <- Filter(is.numeric, partial[1:ncol(partial)-1])
        if (nrow(nums) == 0 || ncol(nums) == 0){
            max_y <- 0
        }
        else {
            max_y <- max(nums[(1:nrow(nums)),1:(ncol(nums))]) # option 1
        }
        max_freq <- max(partial[,ncol(partial)])

        categ <- list()

        # create labels for categorical variables; preserve order
        # if there is a greater max_y, replace
        for(col in 1:(ncol(partial)-1)) {
            # Store the columns that have categorical variables
            if (max_y < nlevels(partial[, col])) {
                max_y <- max(max_y, nlevels(partial[, col]))
            }

            # Preserve order for categorical variables changed in discretize()
            if (!is.null(attr(partial, "categorycol")) &&
                colnames(partial)[col] %in% attr(partial, "categorycol")) {

                # Get the index that the colname is in categorycol
                # categoryorder[index] is the list that you want to assign
                orderedcategories <-
                    attr(partial, "categoryorder")[match(colnames(partial)[col],
                                                         attr(partial, "categorycol"))][[1]]
                categ[[col]] <-
                    orderedcategories[(orderedcategories
                                       %in% c(levels(partial[, col])))]
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
                partial[[col]] = as.numeric(levels(partial[[col]])[partial[[col]]])
            }
        }

        # draw one graph
        # creation of initial plot
        cats <- rep(max_y, width)
        baserow <- c(1, cats)
        if (save) {
            png(paste(name, "png", sep=".")) # Save the file instead of displaying
        }

        # Layout left and right sides for the legend
        generateScreen(10, 6.5)
        graphics::layout(matrix(1:2, ncol=2), width = c(2,1), height = c(1,1))
        par(mar=c(10, 4, 4, 2))
        plot(baserow,type="n", ylim = range(0, max_y),
             xaxt="n", yaxt="n", xlab="", ylab="", frame.plot=FALSE)

        # Add aesthetic
        title(main=name, col.main="black", font.main=4)
        par(mar=c(10, 4, 4, 2))
        axis(1, at=seq(2, width, 2), 
           labels=colnames(partial)[seq(2, width, 2)], cex.axis=1, las=2)
        axis(1, at=seq(1, width, 2), 
           labels=colnames(partial)[seq(1, width, 2)], cex.axis=1, las=2)
        axis(2, at=seq(0,max_y,1))

        # Get scale for lines if large dataset
        if(max_freq > 500){
            scale <- 0.10 * max_freq
        } else {
            scale <- 1
        }

        colfunc <- colorRampPalette(c("red", "yellow", "springgreen", "royalblue"))

        # add on lines
        for(i in 1:nrow(partial)) {
            row <- partial[i,1:width]
            row <- as.numeric(row)

            # Scale everything from 0 to 1, then partition into 20 for colors
            fr <- partial[i, width+1] / scale # determine thickness via frequency

            max_freq <- max(partial[,ncol(partial)])
            min_freq <- min(partial[,ncol(partial)])
            fr <- (fr-min_freq) / (max_freq-min_freq)
            fr <- round(fr / (0.05))

            fr <- round(fr) + 1

            # Account for if there is only one frequency
            if (!is.finite(fr)) {
                fr = 11
            }

            lines(row, type='o', col=colfunc(21)[fr],
                  lwd=fr) # add plot lines

            if (!missing(labelsOff) && labelsOff == FALSE) {
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

        legend_image <- as.raster(matrix(rev(colfunc(20)), ncol=1))
        plot(c(0,2),c(0,1),type = 'n', axes = F,
             xlab = '', ylab = '', main = 'Frequency')
        text(x=1.5, y = seq(1, 0, l=5), labels = seq(round(max_freq),
                                                     round(min_freq), l=5))
        rasterImage(legend_image, 0, 0, 1, 1)
}

###########################  interactivedraw  ################################

# Accepts a result from tupleFreqs and draws interactively using plotly
# Plots will open in browser and be saveable from there
# requires GGally and plotly
interactivedraw <- 
   function(pna, name="Interactive Parcoords",differentiate=FALSE,
      colorPalette,sameGraphGrpVar,jitterVal) 
{
    # How it works:
    # Plotly requires input by columns of values. For example,
    # we would take col1, col2, col3, each of which has 3 values.
    # Then, col1.val1, col2.val1, col3.val1 would make one line.
    # For categorical variables, we map each unique variable, found
    # with factors, down to a corresponding number. We then substitute
    # this number in the original dataset, then plot it. Finally,
    # we use our mapping from labels to numbers to actually demonstrate
    # which categorical variable represents what.

    if (!is.null(jitterVal)) {
       # add jitter, so lines are not coincident on each other
       nrowsPNA <- nrow(pna)
       nms <- names(pna)
       for (i in 1:(ncol(pna)-1)) {
          # if doing same-graph grouping, need to skip the original
          # group column
          # if (nms[i] == sameGraphGrpVar) next
          pnai <- pna[,i]
          avg <- mean(pnai)
          pna[,i] <- pnai + avg * jitterVal * rnorm(nrowsPNA)
       }
    }

    # create list of lists of lines to be inputted for Plotly
    interactiveList <- list()

    # Store categorical variables - categ[[i]] holds the ith column's unique
    # variables. If categ[[i]] is null, that means it is not categorical.
    categ <- list()
    # Map unique categorical variables to numbers
    for(colnum in 1:(ncol(pna)-1)) {
        # Store the columns that have categorical variables

        # Preserve order for categorical variables changed in discretize()
        if (!is.null(attr(pna, "categorycol")) &&
            colnames(pna)[colnum] %in% attr(pna, "categorycol")) {

            # Get the index that the colname is in categorycol
            # categoryorder[index] is the list that you want to assign
            orderedcategories <-
                attr(pna, "categoryorder")[match(colnames(pna)[colnum],
                                                 attr(pna, "categorycol"))][[1]]
            categ[[colnum]] <- orderedcategories[(orderedcategories %in%
                                                  c(levels(pna[, colnum])))]
        }
        # Convert normal categorical variables
        else {
            categ[[colnum]] <- c(levels(pna[, colnum]))
        }

        # if this column has categorical variables, change its values
        # to the corresponding numbers accordingly.
        if (colnum <= length(categ) && !is.null(categ[[colnum]])){
            for(j in 1:(nrow(pna))){
                tempval <- which(categ[[colnum]] == pna[j,colnum])
                # Stop factorizing while we set the value
                pna[[colnum]] = as.character(pna[[colnum]])
                pna[j, colnum] <- tempval[1]

                # After setting the value, reset factors
                pna[[colnum]] = as.factor(pna[[colnum]])
            }
            # Stop factorizing now that all values are numbers
            pna[[colnum]] = as.numeric(levels(pna[[colnum]])[pna[[colnum]]])
        }
    }

    # find the max value and the max frequency to set max/min for our plot
    nums <- Filter(is.numeric, pna)
    max_y <- max(nums[(1:nrow(nums)),1:(ncol(nums) - 1)]) # option 1
    max_freq <- max(pna[,ncol(pna)])
    min_freq <- min(pna[,ncol(pna)])

    # update max value for categorical variables, not including freq
    for(i in 1:(ncol(pna)-1)){
        if (max_y < nlevels(pna[, i])){
            max_y <- nlevels(pna[, i])
        }

        # Create list of lists for graphing

        # If it is a categorical variable, add ticks and labels
        if (i <= length(categ) && !is.null(categ[[i]])){
            if (length(categ[[i]]) == 1){
                interactiveList[[i]] <-
                    list(range = c(0, 2),
                         label = colnames(pna)[i],
                         values = unlist(pna[,i]),
                         tickvals = 0:2,
                         ticktext = c(" ", categ[[i]][[1]], " ")
                         )
            }
            else {
                # Add spaces before and after every category label
                # There appears to be a plotly bug with some numbers as labels.
                # This gets around that.
                # Related issue: https://github.com/ropensci/plotly/issues/1096
                for (labelCounter in 1:length(categ[[i]])) {
                    categ[[i]][[labelCounter]] = paste(paste(' ', categ[[i]][[labelCounter]]), ' ')
                }

                interactiveList[[i]] <-
                    list(range = c(1, length(categ[[i]])),
                         constraintrange = c(1, length(categ[[i]])),
                         label = colnames(pna)[i],
                         values = unlist(pna[,i]),
                         tickmode = 'array',
                         tickvals = 1:length(categ[[i]]),
                         ticktext = categ[[i]]
                         )
            }
        }
        # Otherwise, you don't need special ticks/labels
        else {
            interactiveList[[i]] <-
                list(range = c(min(pna[[i]]), max(pna[[i]])),
                     tickformat = ':2f',
                     constraintrange = c(min(pna[[i]]), max(pna[[i]])),
                     label = colnames(pna)[i],
                     values = unlist(pna[,i]))
        }
    }

    scaleOn <- TRUE

    # Use random colors to differentiate lines
    if (differentiate) {
        nrpna <- nrow(pna)
        pna$freq <- sample(1:nrpna,nrpna,replace=FALSE)
        min_freq <- 1
        max_freq <- nrow(pna)
        scaleOn <- FALSE
    }

    # Convert pna to plot
    if(!is.null(sameGraphGrpVar)) {
       colorCode <- pna[[sameGraphGrpVar]]
    } else colorCode <- pna$freq

    if (name == "") {
        ## unnecessary dependency on pipes removed by NM
        ## pna %>%
        ##     plot_ly(type = 'parcoords',
            plot_ly(pna,type = 'parcoords',
                    line = list(color = pna$freq,
                                colorscale = 'Jet',
                                showscale = scaleOn,
                                reversescale = TRUE,
                                cmin = min_freq,
                                cmax = max_freq),
                    dimensions = interactiveList)
    }
    else {
        if (!is.null(sameGraphGrpVar)) {
           colorscale = list(c(0,'#66FF00'),c(1,'#EE4B2B'))
           showscale = FALSE
        } else {
           colorscale <- 'Plasma'
           showscale = scaleOn
        }
        tmp <- plot_ly(pna, type = 'parcoords',
                  line = list(
                            # color = pna$freq,
                            color = colorCode,
                            # colorscale = 'Jet',
                            # colorscale = colorPalette,
                            colorscale = colorscale,
                            showscale = showscale,
                            reversescale = TRUE,
                            cmin = min_freq,
                            cmax = max_freq),
                  dimensions = interactiveList)
        tmp <- layout(tmp,margin = list(r=50))
        plotly::layout(tmp,title=name)
    }
}

###########################  discparcoord  ################################

# This is the main function. It ties together all of the other functions.
# 1. data: The dataset; if character string, tuple counts will be read
#   from 'tupleCounts' instead of re-calling tupleFreqs(). Or if class
#   'pna', the in-memory saved tuple counts will be used.
# 2. k: The number of most-frequent tuples to keep
# 3. grpcategory: Categories to keep constant
# 4. permute: Whether or not to permute the columns.
#   This is not used by default, as interactivedraw has this feature.
# 5. interactive: Which type of plotting to use - interactive or not. By default,
#   it uses interactive.
# 6. save: Whether or not to save the plot drawn. By default, this is
#   off as interactive has this feature embedded.
# 7. name: The name for the plot
# 8. labelsOff: Whether or not to use labels.
# 9. NAexp: Emphasis of NA values.
# 10. countNAs: Whether or not to count NA values.
# 11. accentuate: Whether or not to accentuate a few lines. This is useful
#   for differentiating lines that are close/blended, if you don't want to
#   use the filtering in interactive mode.
# 12. accval: The value to accentuate.
# 13. inParallel: Whether or not to run this function in parallel.
# 14. cls: If running in parallel, the cluster.
# 15. differentiate: Whether or not you want to randomize coloring
#   to differentiate overlapping lines.
# 16. saveCounts: Passed to tupleFreqs(); if TRUE, tuple counts will be
#   saved to 'tupleCounts'.
# 17. minFreq: Passed to tupleFreqs().  If non-null, exclude tuples have
#   frequencies below this level.

discparcoord <- function(data, k = 5, grpcategory = NULL, permute = FALSE,
                         interactive = TRUE, save = FALSE, name = "Parcoords",
                         labelsOff = TRUE, NAexp = 1.0, countNAs = FALSE,
                         accentuate = NULL, accval = 100, inParallel = FALSE,
                         cls = NULL, 
                         # differentiate = FALSE,
                         differentiate = TRUE,  # NM, Feb. 2025
                         saveCounts = FALSE, minFreq=NULL,
                         # new args, Feb. 2025
                         jitterVal = NULL,
                         sameGraphGrpVar = NULL,
                         colorPalette = 'Jet'
                         ) 
{

    if (class(data)[1] == 'pna' && !is.null(grpcategory)) {
        stop('group case does not yet handle preprocessed data')
    }
    if (!is.null(grpcategory) && !is.null(accentuate)) {
        stop('group case does not yet handle use of "accentuate" option')
    }

    if(!is.null(sameGraphGrpVar)) {
       if (!is.null(grpcategory))
          stop('at most one of grpcategory and sameGraphGrpVar can be non-null')
       if (!interactive)
          stop('sameGraphGrpVar can be used only if interactive is TRUE')
       if (!(sameGraphGrpVar %in% names(data)))
          stop('invalid sameGraphGrpVar')
       if (differentiate) {
          differentiate <- FALSE
          print("'differentiate' changed to FALSE")
       }
    }

    if (!is.null(jitterVal)) {
       varClasses <- sapply(data,class)
       if (!all(varClasses == 'numeric')) {
          stop('need all numeric columns for jitter')
          print('use regtools::factorsToDummies to convert to numerics')
       }
    }

    # check to see if column name is valid
    if(!(grpcategory %in% colnames(data)) && !(is.null(grpcategory))) {
        stop("Invalid column names")
    }
    # check to see if grpcategory given
    else if (is.null(grpcategory)) {  # no grouping
        # check whether already have tuple counts
        if (class(data)[1] == 'pna' || class(data) == 'character') {
            if (class(data)[1] == 'pna') {  # from in-memory saved counts
                partial <- data
            } else {  # from on-disk saved counts
                counts <- 0  # for CRAN
                load('tupleCounts')  # loads 'counts'
                partial <- counts
            }
            if (!is.null(minFreq)) {
                partial <- partial[partial$freq >= minFreq,]
            }

            ktmp <- attr(partial,'k')

            if (ktmp > k) {
                stop('proposed k larger than in saved counts')
            }

            k <- min(ktmp, nrow(partial))
            ordering <- order(partial$freq,decreasing=(k > 0))
            partial <- partial[ordering[1:abs(k)],]
        } else {  # need to compute tuple counts
            # get top k
            if (!inParallel) { partial <- 
                tupleFreqs(data,k=k,NAexp=NAexp,countNAs,saveCounts=saveCounts,minFreq,
                   accentuate=accentuate,accval=accval)
            }
            else {
                partial <- clsTupleFreqs(cls, data, k=k, NAexp=NAexp, countNAs)
            }

            # to permute or not to permute
            if(permute){
                partial = partial[,c(sample(ncol(partial)-1), ncol(partial))]
            }
        }

        if (!interactive) {
            draw(partial, name=name, save=save, labelsOff=labelsOff,
               colorPalette)
        }
        else {
            interactivedraw(partial,name=name,differentiate=differentiate,
               colorPalette,sameGraphGrpVar,jitterVal)
        }
    }
    # grpcategory is given and is valid
    else {
        lvls <- unique(data[[grpcategory]])

        # generate a list of plots for grpcategory
        plots <- list()

        # iterate through each different value in the selected category
        for(i in 1:length(lvls)){
            cat <- lvls[i]
            ctgdata <- data[which(data[[grpcategory]] == cat), ]
            ctgdata[[grpcategory]] <- NULL

            if (!inParallel) {
                partial <- tupleFreqs(ctgdata, k=k, NAexp=NAexp,
                                     countNAs=countNAs,saveCounts=saveCounts)
            } else {
                partial <- clsTupleFreqs(cls, ctgdata, k=k, NAexp=NAexp,
                                        countNAs = countNAs)
            }

            if(permute) {
                partial <- partial[,c(sample(ncol(partial)-1), ncol(partial))]
            }

            if (!interactive) {
                # Saving is only an option on noninteractive plotting
                if (save) {
                    draw(partial, name=paste(name, cat), save=save, 
                       labelsOff=labelsOff)
                } else {
                    draw(partial, name=paste(name, cat), labelsOff=labelsOff)
                }
            } else {
                numcat <- paste(i, cat)
                fullname <- paste(name, numcat)
                plots[[i]] <-
                    interactivedraw(partial,
                                    name=fullname,
                                    differentiate=differentiate)
            }
        }
        return(plots)
    }
}

###########################  generateScreen  ################################

# Create a new screen for grpcategory
generateScreen <- function(width, height) {
  dev.new(width=width, height=height)
}

