
setwd("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project")

train <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv")
test <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv")

## Run to regenerate test file without Address
# test$Address <- NULL
# write.csv(test, "SF Data/testWithoutAddress.csv")

### Starts up H2O 
# library(h2o)
# h2o.init(nthreads = -1) # Start with all CPUs

pathToFolder <- "C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv"
train.hex = h2o.importFile(path = pathToFolder,
                           destination_frame = "train.hex")

# pathToFolder <- "C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv"
# test.hex = h2o.importFile(path = pathToFolder,
#                           destination_frame = "test.hex")

# For test with Address removed
pathToFolder <- "C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/testWithoutAddress.csv"
test.hex = h2o.importFile(path = pathToFolder,
                          destination_frame = "test.hex")

x <- c("DayOfWeek", "PdDistrict", "X", "Y")
y <- "Category"

RandomForest <- h2o.randomForest(x, 
                                 y, 
                                 training_frame = train.hex, 
                                 ntree = 50)

RFModelTest <- h2o.predict(RandomForest, test.hex)
RFTestDf <- as.data.frame(RFModelTest)


