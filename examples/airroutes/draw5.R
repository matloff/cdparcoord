library(plotly)
library(dplyr)

#ds <- read.csv("pna5-100.csv", header=FALSE, row.names=NULL, fill=TRUE, na="", col.names=c("Airport1", "lat1", "long1", "Airport2", "lat2", "long2", "Airport3", "lat3", "long3", "Airport4", "lat4", "long4", "Airport5", "lat5", "long5", "freq"))
#ds <- read.csv("pna5-500.csv", header=FALSE, row.names=NULL, fill=TRUE, na="", col.names=c("Airport1", "lat1", "long1", "Airport2", "lat2", "long2", "Airport3", "lat3", "long3", "Airport4", "lat4", "long4", "Airport5", "lat5", "long5", "freq"))
ds <- read.csv("pna5-1000.csv", header=FALSE, row.names=NULL, fill=TRUE, na="", col.names=c("Airport1", "lat1", "long1", "Airport2", "lat2", "long2", "Airport3", "lat3", "long3", "Airport4", "lat4", "long4", "Airport5", "lat5", "long5", "freq"))
#air <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2011_february_us_airport_traffic.csv')
air <- read.csv("us_airports.csv")

remove <- c()

for (i in nrow(air):1) {
  air[i,]$cnt <- 0
  airport <- as.character(air[[1]][[i]])

  count <- 0

  # If the airport doesn't show up at all, don't draw it
  if (length(which(ds$Airport1 == airport)) == 0 &&
      length(which(ds$Airport2 == airport)) == 0 &&
      length(which(ds$Airport3 == airport)) == 0 &&
      length(which(ds$Airport4 == airport)) == 0 &&
      length(which(ds$Airport5 == airport)) == 0) {
    remove <- c(remove, i)
  }
  else {
    if (length(which(ds$Airport1 == airport)) != 0) {
      count <- count + sum(ds[which(ds$Airport1 == airport),]$freq)
    }
    if (length(which(ds$Airport2 == airport)) != 0) {
      count <- count + sum(ds[which(ds$Airport2== airport),]$freq)
    }
    if (length(which(ds$Airport3 == airport)) != 0) {
      count <- count + sum(ds[which(ds$Airport3== airport),]$freq)
    }
    if (length(which(ds$Airport4 == airport)) != 0) {
      count <- count + sum(ds[which(ds$Airport4== airport),]$freq)
    }
    if (length(which(ds$Airport5 == airport)) != 0) {
      count <- count + sum(ds[which(ds$Airport5== airport),]$freq)
    }
    if (count > 0) {
      air[i,]$cnt <- count * 50
    }
    #print(count)
  }
}

# All airports that actually show up
air <- air[-remove,]

geo <- list(
            scope = 'north america',
            projection = list(type = 'azimuthal equal area'),
            showland = TRUE,
            landcolor = toRGB("gray95"),
            countrycolor = toRGB("gray80")
            )

#cols <- c("red", "blue", "black", "green", "orange", "cyan")

maxFreq <- max(ds$freq)
minFreq <- min(ds$freq)
range <- maxFreq - minFreq

middle <- range * 2 / 3
bottom3 <- range/3

colfunc <- colorRampPalette(c("red", "yellow", "springgreen", "royalblue"))
#colfunc <- colorRampPalette(c("royalblue", "springgreen", "yellow", "red"))
#colfunc <- colorRampPalette(c("green", "yellow", "red"))
palette <- colfunc(range)

p <- plot_geo(locationmode = 'USA-states', colors="YlOrRd") %>%
  add_markers(
    data = air, x = ~long, y = ~lat, text = ~iata,
    size = ~cnt, hoverinfo = "text", alpha = 0.5
  ) %>%
  layout(
    title = 'Frequency-based Flight Analysis',
    geo = geo, showlegend = FALSE, height=800
  )

for (i in 1:nrow(ds)) {
#for (i in nrow(ds):1) {
  if (as.character(ds$Airport1[i]) == as.character(ds$Airport3[i])) {
    next
  }

  s <- 1
  if (ds$freq[i] - minFreq > middle) {
    s <- 20
  }
  else if (ds$freq[i] - minFreq > bottom3) {
    s <- 10 
  }
  p <- p %>%
    add_segments(
      data = ds[i,],
      x = ds$long1[i], xend = ds$long2[i],
      y = ds$lat1[i], yend = ds$lat2[i],
      alpha = 0.3, size = I(s), hoverinfo = "none",
      line = list(color=palette[ds$freq[i] - minFreq])
    ) %>%
    add_segments(
      data = ds[i,],
      x = ds$long2[i], xend = ds$long3[i],
      y = ds$lat2[i], yend = ds$lat3[i],
      alpha = 0.3, size = I(s), hoverinfo = "none",
      line = list(color=palette[ds$freq[i] - minFreq])
    ) %>%
    add_segments(
      data = ds[i,],
      x = ds$long3[i], xend = ds$long4[i],
      y = ds$lat3[i], yend = ds$lat4[i],
      alpha = 0.3, size = I(s), hoverinfo = "none",
      line = list(color=palette[ds$freq[i] - minFreq])
    ) %>%
    add_segments(
      data = ds[i,],
      x = ds$long4[i], xend = ds$long5[i],
      y = ds$lat4[i], yend = ds$lat5[i],
      alpha = 0.3, size = I(s), hoverinfo = "none",
      line = list(color=palette[ds$freq[i] - minFreq])
    ) 
}
