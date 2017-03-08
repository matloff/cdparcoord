library(plyr)

# possible optimization -> add in R code to find the # of columns first


# Converts continuos numeric data to discrete categorical (1st run)
# POSSIBLE IMPROVEMENTS:
#   FIND A WAY TO MAKE LOWER AND UPPER INTO ONE
# parameters:
#   dataset - table with column that needs to be converted
#   col - column number to be converted
#   cats - labels for discretized variables (MUST BE EQUAL TO length(lower))
#   lower - lower bounds in a vector (LENGTH MUST BE EQUAL TO UPPER)
#   upper - upper bounds in a vector (LENGTH MUST BE EQUAL TO LOWER)
cats = c('one', 'two', 'three')
lower = c(0.5, 1.5, 2.5)
upper = c(1.5,2.5,3.5)

discreteCol = function(dataset, col, cats, lower, upper){
  # need to add in error checking to make sure parameters follow rules
  oldCol = dataset[, col]
  
  newColumn = sapply(oldCol, function(x){
    print(x)
    for(i in 1:length(cats)){
      if((x >= lower[i]) & (x < upper[i]) & !is.na(x)){
        return(cats[i])
      }
    }
    
    return(NA)
  })
    
  dataset[,col] = newColumn
  
  return(dataset)
}


# currently counts all partials and adds them properly
# parameters:
#   dataset (table): dataset to calculate partials for
#   n (int): how many top rows to return (DEFAULT = 5)
partialNA = function (dataset, n){
  count = count(dataset, vars = NULL, wt_var = NULL)
  dimensions = dim(count)
  rows = dimensions[1]
  columns = dimensions[2]
  #NAValues = rep(NA, sum(is.na(count)))
  #CompleteTuple = rep(NA, rows - sum(is.na(count)))
  NAValues = c()
  CompleteTuple = c()
  
  for(i in 1:rows){
    if(sum(is.na(count[i, ])) > 0 ) {
      count[i, columns] = count[i, columns] * (((columns - 1) - sum(is.na(count[i, ]))) / as.numeric(columns - 1))
      NAValues = c(NAValues, i)
    }
  }
  
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
  
  count
  return(count)
}

# output parallel coordinates plot as Rplots.pdf
# name: name for plot
draw = function(partial, name) {


  width <- ncol(partial)-1
  # max_y <- max(partial[1:nrow(partial),width]) # option 1
  # get only numbers
  nums <- Filter(is.numeric, partial)
  max_y <- max(nums)
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
  if (missing(name)){
    pdf("plot1.pdf")
  }
  else {
    pdf(name)
  }
  plot(baserow,type="n", xaxt="n",yaxt="n", xlab="",ylab="", frame.plot=FALSE)
  
  # Add aesthetic
  title(main="Parallel Coordinates", col.main="red", font.main=4)
  axis(1, at=1:width, lab=head(colnames(partial), -1))
  axis(2, at=seq(1,max_y,1))
  
  # Get scale for lines if large dataset
  if(max_freq > 500){
    scale <- 0.10 * max_freq
  } else {
    scale <- 1
  }
  
  # add on lines
  for(i in 1:nrow(partial)){
      row <- partial[i,1:width]
      row <- as.numeric(row)
      fr <- partial[i, width+1] / scale # determine thickness via frequency
      lines(row, type='o', col="green", lwd=fr) # add plot lines

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

# n (int) - how many top tuples to plot
# categ (int) - plot separately the categ'th col
testpna <- function(n, categ) {
  #data(dataset)

  dataset <- read.csv("data/dataset2.csv")
  
  # select top n frequencies
  if (missing(n)){
    partial <- partialNA(dataset)  
  }
  else {
    partial <- partialNA(dataset, n)
  }

  # create separate plots
  if (!missing(categ)){
    # make sure categ is < numCols
    if (n < ncol(partial)){
      print(unique(partial[,n]))
      options <- unique(partial[,n])
      for(element in options){
        subset <- partial[ which(partial[,n] == element),]
        draw(subset, paste(element, ".pdf", sep="")) 
      }
    }
  }

  # create one plot with everything
  draw(partial) 
}
testpna()
