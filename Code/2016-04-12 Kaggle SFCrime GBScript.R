library(data.table)
library(xgboost)
library(caret)

setwd("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project")

train <- fread('C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv')
test <- fread('C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv')
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

feature.names <- names(data)[which(!(names(data) %in% c('Id', 'Address', 'Dates', 'Category', 'Class')))]
for (feature in feature.names){
    if (class(data[[feature]]) == 'character'){
        cat(feature, 'converted\n')
        levels <- unique(data[[feature]])
        data[[feature]] <- as.integer(factor(data[[feature]], levels=levels))
    }
}

param <- list(
                #nthread             = 4,
                booster             = 'gbtree',
                objective           = 'multi:softprob',
                num_class           = m,
                eta                 = 1.0,
                #gamma               = 0,
                max_depth           = 6,
                #min_child_weigth    = 1,
                max_delta_step      = 1
                #subsample           = 1,
                #colsample_bytree    = 1,
                #early.stop.round    = 5
)

h <- sample(1:length(idx), floor(9*length(idx)/10))
dval <- xgb.DMatrix(data=data.matrix(data[idx[-h], feature.names, with=FALSE]), label=data[idx[-h]]$Class)
dtrain <- xgb.DMatrix(data=data.matrix(data[idx[h], feature.names, with=FALSE]), label=data[idx[h]]$Class)
watchlist <- list(val=dval, train=dtrain)
bst <- xgb.train( params            = param,
                  data              = dtrain,
                  watchlist         = watchlist,
                  verbose           = 1,
                  eval_metric       = 'mlogloss',
                  nrounds           = 30 # originally 15
)

# making predictions
dtest <- xgb.DMatrix(data=data.matrix(data[-idx,][order(Id)][,feature.names, with=FALSE]))
prediction <- predict(bst, dtest)
prediction <- sprintf('%f', prediction)
prediction <- cbind(data[-idx][order(Id)]$Id, t(matrix(prediction, nrow=m)))
dim(prediction)

colnames(prediction) <- c('Id', classes)
#names(prediction)
write.csv(prediction, 'Submissions/2016-04-13-04 GB PCA nrounds 43.csv', row.names=FALSE, quote=FALSE)
#zip('submission.zip', 'submission.csv')