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
  max_freq <- max(partial[,width+1])

  categ <- list()
  
  # create labels for categorical variables
  # if there is a greater max_y, replace
  for(i in 1:(ncol(partial))){
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
  plot(baserow,type="n", ylim = range(0,max_y), xaxt="n",yaxt="n", xlab="",ylab="", frame.plot=FALSE)
  
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
  legend("bottomright", legend=seq(1, min(20, round(max_freq, digits=0))), pch=19, col=colfunc(min(20, round(max_freq, digits=0))))

  maxfreq <- max(partial[,-1])
  
  # add on lines
  for(i in 1:nrow(partial)){
      row <- partial[i,1:width]
      row <- as.numeric(row)
      fr <- partial[i, width+1] / scale # determine thickness via frequency

      lines(row, type='o', col=colfunc(maxfreq)[round(partial[i, width+1]/scale, digits=0)], lwd=fr) # add plot lines

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
}

smallexample <- function(n, categ) {
  dataset = data(smallexample)

  # select top n frequencies
  if (missing(n)){
    partial <- partialNA(dataset)  
  }
  else {
    partial <- partialNA(dataset, n)
  }
  #draw(partial)
}

# this is the main graphing function - use this
# data should be input as a dataframe
# need to figure out how to DISCRETIZE COLUMNS 
# 1. permute columns
# 2. interactive columns
# 3. figure out labeling program
# 4. Need to add in a way to choose which names to label pdfs with
disparcoord <- function(data, k = NULL, grpcategory = NULL, permute = FALSE){
  
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
