#install.packages("ggplot2")
#library(ggplot2)
data2 <- read.csv("Outputs/processed.tsv", header = F, sep=" ")

# The data is in reverse, this loops orders it correctly
for (i in 1:3){
  data2[,i] <- rev(data2[,i])
}

data2
data2len <- length(data2[,1])
head(data2[,1])
png('Outputs/bg-graph.png', width = 1920, height = 1080, units = "px")
plot(data2[,3], type = "o", xlab="Date", ylab="mmol/L", xaxt="n", yaxt="n")
grid(nx = data2len, ny = 20, col = "lightgray", lty = "dotted", lwd = par("lwd"), equilogs = F)
legend(1, 9, legend=c("Normal Range", "Average"),
       col=c("red", "blue"), lty=1, cex=0.8, bg = "white")
split_date = as.Date(data2[,1], "%d.%m.%Y") -min(as.Date(data2[,1], "%d.%m.%Y"))
datelen <- length(split_date)
for (i in 1:datelen){
  split_date[[i]] = split_date[[i]]+1
}
split_date

lower = 1

for (i in 1:data2len) {
  
  text(c(lower:lower), par("usr")[3], labels = data2[,1][i], srt = 45,
       adj = c(1.1,1.1), xpd = TRUE, cex=0.8, col = split_date[[i]])
  text(c(lower:lower), par("usr")[4], labels = data2[,2][i], srt = 45, 
       adj = c(0.01,0.01), xpd = TRUE, cex=0.8, col = split_date[[i]])
  
  lower = lower+1
}

yscale2 <- seq(from = 1, to = 10, by = 0.2)
axis(side = 2, at = yscale2)
axis(side = 4, at = yscale2)


abline(a = 0, b = 0, h = c(4,6), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "red")
abline(a = 0, b = 0, h = mean(data2[,3]), v = NULL, reg = NULL,
       coef = NULL, untf = FALSE, col = "blue")

dev.off()



