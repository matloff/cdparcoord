
library(cdparcoord)
airports <- read.csv("airports.csv")
loc <- airports[c(1, 6, 7)] # grab code, lat, long

a <- read.csv("full5.csv", header=FALSE, row.names=NULL, fill=TRUE, na="")

ds <- partialNA(a, k=500)
