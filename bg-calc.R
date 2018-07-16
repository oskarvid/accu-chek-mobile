#install.packages("lubridate")
library("lubridate")
data2 <- read.table("Outputs/processed.tsv", header = F, sep="\t")
dim(data2)

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

# Define image output directory and size
png('Outputs/bg-graph.png', width = wd, height = 1080)

# Define the colors
palette(c("black", "red", "green", "blue", "magenta"))

# Create the plot
plot(data2[,3], type = "o", xlab="Date", ylab="mmol/L", xaxt="n", yaxt="n", 
     pch=as.numeric(data2[,5]), col=split_date, cex = 3)

# Make grid for plot
data2len <- length(data2[,1])
grid(nx = data2len, ny = (data2len/2), col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)

# Create dynamic placement of legend
upper <- range(data2[,3])
position = 0.94*upper
position

# Make legend
legend(-2, position[2], legend=c("Normal Range", 
                                 "Average", 
                                 "Median", 
                                 "Other",
                                 "Before meal", 
                                 "After meal", 
                                 "Missing data"),
       col=c("red", "blue", "green", "black", "black", "black", "black"), 
       lty=c(1, 1, 1, NA, NA, NA, NA), cex=1.2, bg = "white", pch = c(NA, NA, NA, 1, 2, 3, 0))


# Print the time and date in specific color to make it easier to identify specific days
lower = 1
for (i in 1:data2len) {
  
  text(c(lower:lower), par("usr")[3], labels = data2[,1][i], srt = 45,
       adj = c(1.1,1.1), xpd = TRUE, cex=0.8, col = split_date[[i]])
  text(c(lower:lower), par("usr")[4], labels = data2[,2][i], srt = 45, 
       adj = c(0.01,0.01), xpd = TRUE, cex=0.8, col = split_date[[i]])
  
  lower = lower+1
}

# Create the y-scale, place it on the left and right sides
yscale2 <- seq(from = 1, to = upper[2], by = 0.2)
axis(side = 2, at = yscale2)
axis(side = 4, at = yscale2)

# Create lines for upper and lower blood glucose reference values as well as mean and median bg values
abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")
abline(a = 0, b = 0, h = mean(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "blue")
abline(a = 0, b = 0, h = median(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "green")

# Write image to file
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

# Define image size
wd <- (length(data2[,1])/100)*1920

# Define image name and dimensions
png('Outputs/24h-bg-graph.png', width = wd, height = 1080)

# Create plot
plot(as_date(data4[x,2], origin = Sys.Date()), data4[x,3], pch = as.numeric(data4[x,5]), cex = 2)
legend(as_date(data4[x,2], origin = Sys.Date())[1], 10, legend=c("Other",
                                                                 "Before meal", 
                                                                 "After meal", 
                                                                 "Missing data"),
       col=c("black", "black", "black", "black"), cex=1.2, pch = c(1, 2, 3, 0))

# Write image to file
dev.off()











