library(plyr)

#possible optimization -> add in R code to find the # of columsn first

#currently counts all partials and adds them properly

partialNA = function (dataset){
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
  return(count[complete.cases(count),])
}

# output parallel coordinates plot as Rplots.pdf
draw = function(partial) {
  max_y <- max(partial)
  width <- ncol(partial)-1

  for(i in 1:1){
      row <- partial[i,1:width]
      row <- as.numeric(row)
      fr <- partial[i, width+1]
      # create initial plot
      plot(row, type="o", col="blue", axes=FALSE, ann=FALSE, lwd=fr)
  }

  for(i in 2:nrow(partial)){
      row <- partial[i,1:width]
      row <- as.numeric(row)
      fr <- partial[i, width+1] # determine thickness via frequency
      lines(row, col="green", lwd=fr) # add plot lines
  }

  # Create a title with a red, bold/italic font
  title(main="Parallel Coordinates", col.main="red", font.main=4)
  axis(1, at=1:width, lab=head(colnames(partial), -1))
  axis(2, at=1:max_y)
}

testpna <- function() {
  data(dataset)
  partial = partialNA(dataset)
  partial
  draw(partial)
}
