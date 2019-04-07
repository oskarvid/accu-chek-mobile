#install.packages("lubridate")
library("lubridate")
library("TTR")
library("xts")
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}

#setwd("/home/oskar/01-workspace/00-temp/accu-chek-mobile")
data2 <- read.table("Outputs/processed.tsv", header = F, sep="\t")
#dim(data2)

# Column 5 is empty by default, so it will get all values from column 7 to 9 later, but first populate it with 0's!
data2[,5][is.na(data2[,5])] <- 0

# The data is in reverse, this loops orders it correctly
for (i in 1:dim(data2)[2]){
  data2[,i] <- rev(data2[,i])
}

# Populate empty rows with 0, and convert X to 1, 2 or 3 depending on if it's pre prandial, post prandial or other
index = 7
for (i in 1:3){
  data2[,index] <- sub(" ", "0", data2[,index])
  data2[,index] <- sub("X", i, data2[,index])
  index = index + 1
}

# This nested for loop takes values from column 7, 8 and 9 and puts them in column 5
index = 7
for (i in 1:3){
  for (j in 1:dim(data2)[1]){
    if (data2[,index][j] == i) data2[,5][j] <- data2[,index][j]
  }
  index = index + 1
}

# Verify that it looks correct
#head(data2)

# Make an index for all dates
split_date = as.Date(data2[,1], "%d.%m.%Y") -min(as.Date(data2[,1], "%d.%m.%Y"))
datelen <- length(split_date)
for (i in 1:datelen){
  split_date[[i]] = split_date[[i]]+1
}

lel <- as.data.frame(dmy(as.character(data2[,1])))
lel[,2] <- hm(data2[,2])
#lel[c(387:566),2] <- hm(data2[c(387:566),2]) - hours(1)
lel[,2] <- format(Sys.Date() + lel[,2], "%H:%M")

xts1 <- xts(data2[,3], order.by = lel[,1])
xts1 <- to.period(xts1, period = "days")

png('Outputs/candle-chart.png', width = 1920, height = 1080)
candleChart(xts1, up.col = "black", dn.col = "red", theme = "white")
addSMA(n = 5, col = "purple")
addMACD()
addVolatility()
addBBands()
dev.off()

######################################################
# I tried to make a for loop for these graphs but it wouldn't work, fortunately hard coding will always be there for you in times of need <3
png('Outputs/all-first-values-per-day.png', width = 1920, height = 1080)
plot(xts1[,1], main = "First value per day")
dev.off()

png('Outputs/all-highest-values-per-day.png', width = 1920, height = 1080)
plot(xts1[,2], main = "Highest value per day")
dev.off()

png('Outputs/all-lowest-values-per-day.png', width = 1920, height = 1080)
plot(xts1[,3], main = "Lowest value per day")
dev.off()

png('Outputs/all-last-values-per-day.png', width = 1920, height = 1080)
plot(xts1[,4], main = "last value per day")
dev.off()
######################################################

# Calculate dynamic png width, 100 values equals 1920x1080 size. Height is static.
wd <- (length(data2[,1])/100)*1920

# Create fake data for sample graphs
#len <- length(data2[,2])
#data2[,3] <- round(rnorm(len, m = 5, sd = 1), digits = 1)
#data2[,5] <- round(runif(len, 0, 3), digits = 0)
#head(data2)

# Define image output directory and size
png('Outputs/bg-graph.png', width = wd, height = 1080)

plot(data2[,3], type = "n", xlab="Date", ylab="mmol/L", xaxt="n", yaxt="n")

# Create variable that colors the days gray and white
colors1 <- c("#0000004D", "#FFFFFF4D")
colors2 <- 0
n=1
for (j in 1:200){
  for (i in 1:2){
    colors2[n] <- colors1[i]
    n = n + 1
  }
}

# Create the colored areas for each day
lower = 1
upper = 1
for (i in 1:length(table(as.Date(data2$V1, format="%d.%m.%Y")))) {
  upper = table(as.Date(data2$V1, format="%d.%m.%Y"))[[i]] + upper
  rect(lower, 1, upper, 100, col = colors2[i])
  lower = table(as.Date(data2$V1, format="%d.%m.%Y"))[[i]] + lower
}

# Draw the actual graph
lines(data2[,3], pch=as.numeric(data2[,5]), cex = 1.2, type = "o", lwd = 1, col = "black")

# Draw exponential moving average graph
lines(EMA(data2[,3], n = 15), cex = 1.2, type = "l", lwd = 1, col = "purple")

# Add grid
data2len <- length(data2[,1])
grid(nx = data2len, ny = (data2len/2), col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)

# Calculate legend position
upper <- range(data2[,3])
position = 0.94*upper

# Create the legend
legend(-2, position[2], legend=c("Normal Range", 
                                 "Average", 
                                 "Median", 
                                 "Exponential moving average, n = 10",
                                 "Other",
                                 "Before meal", 
                                 "After meal", 
                                 "Missing data"),
       col=c("red", "blue", "green", "purple", "black", "black", "black", "black"), 
       lty=c(1, 1, 1, 1, NA, NA, NA, NA), cex=1.2, bg = "white", pch = c(NA, NA, NA, NA, 1, 2, 3, 0))

# Print the dates on the bottom and the times on the top of the graph
lower = 1
for (i in 1:data2len) {
  
  text(c(lower:lower), par("usr")[3], labels = data2[,1][i], srt = 45,
       adj = c(1.1,1.1), xpd = TRUE, cex=0.8, col = "black")
  text(c(lower:lower), par("usr")[4], labels = lel[,2][i], srt = 45, 
       adj = c(0.01,0.01), xpd = TRUE, cex=0.8, col = "black")

  lower = lower+1
}

# print the y scales on the left and right side of the graph
yscale2 <- seq(from = 1, to = upper[2], by = 0.2)
axis(side = 2, at = yscale2)
axis(side = 4, at = yscale2)

# Print the normal range lines
abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")

# Print the mean bg line
abline(a = 0, b = 0, h = mean(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "blue")

# Print the median bg line
abline(a = 0, b = 0, h = median(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "green")

dev.off()

## Make second plot
data4 <- data2
data4[,2] <- seconds(hm(lel[,2]))

# Sort data
srtd <- sort(data4[,2])

# create index to print the blood glucose values correctly
x <- 1
for (i in 1:length(srtd)) {
  x[i] <- grep(srtd[i], data4[,2])
}

# Define image name and dimensions
png('Outputs/24h-bg-graph.png', width = 1920, height = 1080)

A1c <- ((2.59 + mean(data2[,3])) / 1.59)

# Create 24h plot
plot(as_date(data4[x,2], origin = Sys.Date()), data4[x,3], 
     main = "*A1c is only a rough estimate, don't rely on it for diagnostic purposes",
     xlab="Time of day", ylab="mmol/L", pch = as.numeric(data4[x,5]), cex = 2, yaxt = "n", type = "n")

# Create legend
legend(as_date(data4[x,2], origin = Sys.Date())[1], (max(data4[,3])*0.94),
       legend=c("Other",
                "Before meal",
                "After meal",
                "Missing data",
                "Simple moving average, n = 35",
                "Normal range",
                "Estimated A1c*"),
       col=c("black", "black", "black", "black", "black", "red", "blue"), cex=1.2, 
       lty = c(NA, NA, NA, NA, 1, 1, 1), pch = c(1, 2, 3, 0, NA, NA, NA))

# Print actual graph
lines(as_date(data4[x,2], origin = Sys.Date()), SMA(data4[x,3], n=35), type = "l", col = "black")


# Estimate A1c, formula taken from https://www.glucosetracker.net/blog/how-to-calculate-your-a1c/
# The data needs to be from the last 3 months to be somewhat accurate. This is only an estimation. 

abline(a = 0, b = 0, h = A1c, v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "blue")

# Print normal bg range
abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")

# Print y scale of the left and right side of the graph
yscale2 <- seq(from = 1, to = upper[2], by = 0.1)
axis(side = 2, at = yscale2)
axis(side = 4, at = yscale2)

# Write image to file
dev.off()

# Define image name and dimensions
png('Outputs/24h-bg-graph-2.png', width = 1920, height = 1080)

A1c <- ((2.59 + mean(data2[,3])) / 1.59)

# Create 24h plot
plot(as_date(data4[x,2], origin = Sys.Date()), data4[x,3], 
     main = "*A1c is only a rough estimate, don't rely on it for diagnostic purposes",
     xlab="Time of day", ylab="mmol/L", pch = as.numeric(data4[x,5]), cex = 2, yaxt = "n")

# Create legend
legend(as_date(data4[x,2], origin = Sys.Date())[1], (max(data4[,3])*0.94),
       legend=c("Other",
                "Before meal",
                "After meal",
                "Missing data",
                "Simple moving average, n = 35",
                "Normal range",
                "Estimated A1c*"),
       col=c("black", "black", "black", "black", "black", "red", "blue"), cex=1.2, 
       lty = c(NA, NA, NA, NA, 1, 1, 1), pch = c(1, 2, 3, 0, NA, NA, NA))

# Print actual graph
lines(as_date(data4[x,2], origin = Sys.Date()), SMA(data4[x,3], n=35), type = "l", col = "black")


# Estimate A1c, formula taken from https://www.glucosetracker.net/blog/how-to-calculate-your-a1c/
# The data needs to be from the last 3 months to be somewhat accurate. This is only an estimation. 

abline(a = 0, b = 0, h = A1c, v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "blue")

# Print normal bg range
abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")

# Print y scale of the left and right side of the graph
yscale2 <- seq(from = 1, to = upper[2], by = 0.1)
axis(side = 2, at = yscale2)
axis(side = 4, at = yscale2)

# Write image to file
dev.off()

# Define image name and dimensions for histogram
png('Outputs/bg-histogram.png', width = 1920, height = 1080)

# Create histogram of bg values
hist(data2[,3], breaks = 50, main = "Histogram of blood glucose values", 
     xlab = "Blood glucose value", ylab = "Frequency", xaxt = "n", freq = F, equidist = F)

# Create variable with histogram data
histdata <- hist(data2[,3], plot = F)
xscale2 <- seq(from = 1, to = (max(data2[,3])+1), by = 0.1)
axis(1, at = xscale2)

# Plot normal distribution curve
curve(dnorm(x, mean=mean(data2[,3]), sd=sd(data2[,3])), add=TRUE, col="darkblue", lwd=2)

# Put legend in histogram plot
legend(mean(xscale2), 1, legend = "Normal distribution", lty = 1, col = "blue", cex = 2)
dev.off()


# Individual days plot
# Set variables for loop
upper <- range(data4[,3])
yscale2 <- seq(from = 1, to = upper[2], by = 0.2)
lower = 1
upper = 0


# Run loop to create plots
for (i in 1:length(table(as.Date(data2$V1, format="%d.%m.%Y")))) {
  upper = table(as.Date(data4$V1, format="%d.%m.%Y"))[[i]] + upper

  # print to png, the .png suffix is missing here, it currently looks ugly if I add it because it become "filename-date-.png", I don't know how to get rid of the "-.png"  
  png(paste('Outputs/DayPlot-', i, "-", data4[upper,1], ".png", sep = ""), width = 1920, height = 1080)

  # Create the plot
  plot(as_date(data4[x,2], origin = Sys.Date()), data4[x,3],
       xlab="Time of day", ylab="mmol/L", pch = as.numeric(data4[x,5]), cex = 2, type = "n", yaxt = "n", 
       main = data4[upper,1])

  # Draw the graph  
  lines(as_date(data4[upper:lower,2], origin = Sys.Date()), data4[upper:lower,3], 
        pch = as.numeric(data4[upper:lower,5]), type = "o")
  
  # Add normal range lines
  abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
         coef = NULL, untf = FALSE, col = "red")
  lower = table(as.Date(data2$V1, format="%d.%m.%Y"))[[i]] + lower

  # Add legend  
  legend((par("usr")[1]*1.000001), (par("usr")[4]*0.98), 
         legend=c("Other",
                  "Before meal", 
                  "After meal", 
                  "Missing data",
                  "Normal range"),
         col=c("black", "black", "black", "black", "red"), cex=1.2, 
         lty = c(NA, NA, NA, NA, 1), pch = c(1, 2, 3, 0, NA))

  # Print y scale
  axis(side = 2, at = yscale2)
  dev.off()
}
