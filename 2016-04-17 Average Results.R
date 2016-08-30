library(data.table)
library(abind)

setwd("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project")

submission1 <- read.csv("Submissions/2016-04-14-02 RF.csv")
submission2 <- read.csv("Submissions/2016-04-14-03 NN")

sampleSubmission <- read.csv(check.names = FALSE, "SF Data/sampleSubmission.csv")
rowIds <- sampleSubmission$Id
colNames <- colnames(sampleSubmission)

submission1$Id <- NULL
submission2$Id <- NULL

submission <- (submission1 + submission2)/2

submission <- data.frame(Id = 0, submission)
submission$Id <- rowIds
colnames(submission) <- colNames

write.csv(submission, row.names = FALSE, file = "Submissions/2016-04-17-03 Average.csv")
