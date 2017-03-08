library(plyr)

# possible optimization -> add in R code to find the # of columns first

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
  cats = rep(max_y, width-1)
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
  
  # add on lines
  for(i in 1:nrow(partial)){
      row <- partial[i,1:width]
      row <- as.numeric(row)
      fr <- partial[i, width+1] # determine thickness via frequency
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
  data(dataset)

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
