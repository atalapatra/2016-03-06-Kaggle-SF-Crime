library(reshape)
library(sqldf)
library(data.table)
library(dplyr)
library(caret)
library(xgboost)

setwd("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project")

train <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv")
test <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv")
temperature <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/sf_downtown_weather.csv")

trainDates <- colsplit(train$Dates, " ", c("Date","Time"))
testDates <- colsplit(test$Dates, " ", c("Date","Time"))
trainDates <- as.data.frame(gsub("-","",trainDates$Date))
testDates <- as.data.frame(gsub("-","",testDates$Date))
colnames(trainDates) <- "DATE"
colnames(testDates) <- "DATE"

test <- cbind(testDates, test)
train <- cbind(trainDates, train)

temperature$DATE <- as.factor(temperature$DATE)

testTemps <- left_join(testDates, temperature, by = "DATE")
trainTemps <- left_join(trainDates, temperature, by = "DATE")

test <- cbind(test, testTemps$TMAX, testTemps$TMIN, testTemps$TAVG)
train <- cbind(train, trainTemps$TMAX, trainTemps$TMIN, trainTemps$TAVG)

names(test)[9:11] <- c("TMAX","TMIN","TAVG")
names(train)[11:13] <- c("TMAX","TMIN","TAVG")

# write.csv(test, row.names = FALSE, "SF Data/testmod2.csv")
# write.csv(train, row.names = FALSE, "SF Data/trainmod2.csv")

data <- merge(train, test, by=c('Dates', 'DayOfWeek', 'Address', 'X', 'Y', 'PdDistrict'), all=TRUE)
n <- nrow(data)

# parsing date
date_and_time <- strptime(data$Dates, '%Y-%m-%d %H:%M:%S')
data$Year <- as.numeric(format(date_and_time, '%Y'))
data$Month <- as.numeric(format(date_and_time, '%m'))
data$Day <- as.numeric(format(date_and_time, '%d'))
data$Week <- as.numeric(format(date_and_time, '%W'))
data$Hour <- as.numeric(format(date_and_time, '%H'))
#data$Minute <- as.numeric(format(date_and_time, '%M'))

# removing not-necessary columns
columns <- c('Descript', 'Resolution')
for (column in columns){
  data[[column]] <- NULL
}

# feature engineering
data$AddressTypeIsOf <- rep(FALSE, n)
data$AddressTypeIsOf[grep('.?of.?', data$Address)] <- TRUE

# X-Y plane rotation using PCA
idx <- with(data, which(Y == 90))
transform <- preProcess(data[-idx, c('X', 'Y'), with=FALSE], method = c('center', 'scale', 'pca'))
pc <- predict(transform, data[, c('X', 'Y'), with=FALSE]) 
data$X <- pc$PC1
data$Y <- pc$PC2
# time features
data$MinuteAbs30 <- abs(as.numeric(format(date_and_time, '%M')) - 30)
#data$Minute <- NULL

# test/train separation
idx <- which(!is.na(data$Category))
classes <- sort(unique(data[idx]$Category))
m <- length(classes)
data$Class <- as.integer(factor(data$Category, levels=classes)) - 1
dim(data)