# This generates a test and training set. It compares
# a dataset with NA's to one without, so you can compare different
# NA-solving methods

library(freqparcoord.cd)

original <- read.csv("../data/Titanic_Passengers.csv", sep=";")
copy <- original

c <- copy 
numElements <- ncol(c) * nrow(c)
numWant <- 3
s <- sample(numElements, numWant) # second number is how many elements you want

# outer list
x <- lapply(s, function(n) floor((n + ncol(c) - 1) / ncol(c)))
# inner list element
y <- lapply(s, function(n) n %% ncol(c) + 1)

for (i in 1:numWant) {
  c[x[[i]],y[[i]]] <- NA
}

trainSize <- floor(nrow(c) * 0.1) + 1

# with NA
train <- c[1:trainSize,]
test <- c[trainSize:nrow(c),]

# without NA
intactTrain <- original[1:trainSize,]
intactTest <- original[trainSize:nrow(original),]

freqTrain <- partialNA(train)
freqTrainIntact <- partialNA(intactTrain)

freqTest <- partialNA(test)
freqIntactTest <- partialNA(intactTest)

# comparison
