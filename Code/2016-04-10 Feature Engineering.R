
setwd("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project")

train <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/train.csv")
test <- read.csv("C:/Users/Amit/OneDrive/1 - GWU MSBA/DNSC 6279 Data Mining/Kaggle Project/SF Data/test.csv")

# functions to make variables from date info.
make_vars_date <- function(crime_df) {
  crime_df$Years = strftime(strptime(crime_df$Dates,
                                     "%Y-%m-%d %H:%M:%S"),"%Y")
  crime_df$Month = strftime(strptime(crime_df$Dates,
                                     "%Y-%m-%d %H:%M:%S"),"%m")
  crime_df$DayOfMonth = strftime(strptime(crime_df$Dates,
                                          "%Y-%m-%d %H:%M:%S"),"%d")
  crime_df$Hour = strftime(strptime(crime_df$Dates,
                                    "%Y-%m-%d %H:%M:%S"),"%H")
  crime_df$YearsMo = paste( crime_df$Years, crime_df$Month , 
                            sep = "-" )
  crime_df$DayOfWeek = factor(crime_df$DayOfWeek,
                              levels=c("Monday","Tuesday",
                                       "Wednesday","Thursday",
                                       "Friday","Saturday","Sunday"),
                              ordered=TRUE)
  crime_df$weekday = "Weekday"
  crime_df$weekday[crime_df$DayOfWeek== "Saturday" | 
                     crime_df$DayOfWeek== "Sunday" | 
                     crime_df$DayOfWeek== "Friday" ] = "Weekend"
  addr_spl = strsplit(as.character(crime_df$Address),"/")
  crime_df$AddressType = "Non-Intersection"
  ind_l = vector()
  ind_inxn = sapply(1:dim(crime_df)[1], 
                    function(x) length(addr_spl[[x]]) == 2)
  crime_df$AddressType[ ind_inxn ]="Intersection"  
  return(crime_df)
}

train <- make_vars_date(train)
test <- make_vars_date(test)

write.csv(train, file = "SF Data/trainmod1.csv")
write.csv(test, file = "SF Data/testmod1.csv")