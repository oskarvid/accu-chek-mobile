#install.packages("lubridate")
library("lubridate")
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

# Calculate dynamic png width, 100 values equals 1920x1080 size. Height is static.
wd <- (length(data2[,1])/100)*1920

# Create fake data for sample graphs
#len <- length(data2[,2])
#data2[,3] <- round(rnorm(len, m = 5, sd = 1), digits = 1)
#data2[,5] <- round(runif(len, 0, 3), digits = 0)
#head(data2)

# Define image output directory and size
png('Outputs/bg-graph.png', width = wd, height = 1080)
adjustcolor(palette(c("black", "white", "green", "blue", "magenta")), alpha.f = 0.3)
plot(data2[,3], type = "n", xlab="Date", ylab="mmol/L", xaxt="n", yaxt="n")

colors1 <- c("#0000004D", "#FFFFFF4D")
colors2 <- 0
n=1
for (j in 1:200){
  for (i in 1:2){
    colors2[n] <- colors1[i]
    n = n + 1
  }
}

lower = 1
upper = 1
for (i in 1:length(table(as.Date(data2$V1, format="%d.%m.%Y")))) {
  upper = table(as.Date(data2$V1, format="%d.%m.%Y"))[[i]] + upper
  rect(lower, 1, upper, 100, col = colors2[i])
  lower = table(as.Date(data2$V1, format="%d.%m.%Y"))[[i]] + lower
}

lines(data2[,3], pch=as.numeric(data2[,5]), cex = 1.2, type = "o", lwd = 1, col = "black")
data2len <- length(data2[,1])
grid(nx = data2len, ny = (data2len/2), col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)

upper <- range(data2[,3])
position = 0.94*upper

legend(-2, position[2], legend=c("Normal Range", 
                                 "Average", 
                                 "Median", 
                                 "Other",
                                 "Before meal", 
                                 "After meal", 
                                 "Missing data"),
       col=c("red", "blue", "green", "black", "black", "black", "black"), 
       lty=c(1, 1, 1, NA, NA, NA, NA), cex=1.2, bg = "white", pch = c(NA, NA, NA, 1, 2, 3, 0))

lower = 1
for (i in 1:data2len) {
  
  text(c(lower:lower), par("usr")[3], labels = data2[,1][i], srt = 45,
       adj = c(1.1,1.1), xpd = TRUE, cex=0.8, col = "black")
  text(c(lower:lower), par("usr")[4], labels = data2[,2][i], srt = 45, 
       adj = c(0.01,0.01), xpd = TRUE, cex=0.8, col = "black")
  
  lower = lower+1
}

yscale2 <- seq(from = 1, to = upper[2], by = 0.2)
axis(side = 2, at = yscale2)
axis(side = 4, at = yscale2)

abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")
abline(a = 0, b = 0, h = mean(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "blue")
abline(a = 0, b = 0, h = median(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "green")

dev.off()

## Make second plot
data4 <- data2
data4[,2] <- seconds(hm(data4[,2]))

# Sort data
srtd <- sort(data4[,2])

# create index to print the blood glucose values correctly
x <- 1
for (i in 1:length(srtd)) {
  x[i] <- grep(srtd[i], data4[,2])
}

# Create moving mean function for the next plot
moving_fun <- function(x, w, FUN, ...) {
  # x: a double vector
  # w: the length of the window, i.e., the section of the vector selected to apply FUN
  # FUN: a function that takes a vector and return a summarize value, e.g., mean, sum, etc.
  # Given a double type vector apply a FUN over a moving window from left to the right, 
  #    when a window boundary is not a legal section, i.e. lower_bound and i (upper bound) 
  #    are not contained in the length of the vector, return a NA_real_
  if (w < 1) {
    stop("The length of the window 'w' must be greater than 0")
  }
  output <- x
  for (i in 1:length(x)) {
    # plus 1 because the index is inclusive with the upper_bound 'i'
    lower_bound <- i - w + 1
    if (lower_bound < 1) {
      output[i] <- NA_real_
    } else {
      output[i] <- FUN(x[lower_bound:i, ...])
    }
  }
  output
}

# Define image name and dimensions
png('Outputs/24h-bg-graph.png', width = 1920, height = 1080)

# Create 24h plot
plot(as_date(data4[x,2], origin = Sys.Date()), data4[x,3],
     xlab="Time of day", ylab="mmol/L", pch = as.numeric(data4[x,5]), cex = 2, yaxt = "n")

legend(as_date(data4[x,2], origin = Sys.Date())[1], (max(data4[,3])*0.94), 
                                                                 legend=c("Other",
                                                                 "Before meal", 
                                                                 "After meal", 
                                                                 "Missing data",
                                                                 "Moving average",
                                                                 "Normal range"),
       col=c("black", "black", "black", "black", "black", "red"), cex=1.2, lty = c(NA, NA, NA, NA, 1, 1), pch = c(1, 2, 3, 0, NA, NA))

lines(as_date(data4[x,2], origin = Sys.Date()), moving_fun(as.numeric(data4[x,3]), 5, mean), type = "l", col = "black")

abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")

yscale2 <- seq(from = 1, to = upper[2], by = 0.2)
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








