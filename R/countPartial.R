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
draw = function(partial) {
  width <- ncol(partial)-1
  #max_y <- max(partial[1:nrow(partial),width])
  # get only numbers
  nums <- Filter(is.numeric, partial)
  max_y <- max(nums)

  categ <- list()

  # create data frames for categorical variables
  for(i in 1:ncol(partial)){
      categ[[i]] <- c(levels(partial[, i]))
      if (max_y < nlevels(partial[, i])){
          max_y <- nlevels(partial[, i])
      }
      # store these per colName; map to number
      # key: varName 
      # val: index 
  }

  # when we plot, for each row, find the corresponding dictionary. 
  # look up key, plot at val for each point. 

  # at the end of the plotting, label each point via key value pair


  # creation of initial plot
  cats = rep(max_y, width-1)
  baserow = c(1, cats) 
  plot(baserow,type="n", xaxt="n",yaxt="n", xlab="",ylab="", frame.plot=FALSE)
  
  # Add aesthetic
  title(main="Parallel Coordinates", col.main="red", font.main=4)
  axis(1, at=1:width, lab=head(colnames(partial), -1))
  axis(2, at=seq(1,max_y,1))
  
  # adds on lines
  for(i in 1:nrow(partial)){
      row <- partial[i,1:width]
      row <- as.numeric(row)
      fr <- partial[i, width+1] # determine thickness via frequency
      lines(row, type='o', col="green", lwd=fr) # add plot lines
  }

  for(i in 1:(ncol(partial)-1)){
      if (!is.null(categ[[i]])){
        for(j in 1:length(categ[[i]])){
            text(i, j, categ[[i]][j])
        }
      }
  }
}

# n (int) - how many top tuples to plot
testpna <- function(n) {
  
  data(dataset)
  if (missing(n)){
    partial <- partialNA(dataset)  
  }
  else {
    partial <- partialNA(dataset, n)
  }
  partial
  draw(partial) 
}
