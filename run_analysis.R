# install "reshape2" package
install.packages("reshape2")
library(reshape2)
filename <- "getdata_dataset.zip"

# download file
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}

#unzip file  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels and features
activityl <- read.table("UCI HAR Dataset/activity_labels.txt")
activityl[,2] <- as.character(activityl[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract mean and standard deviation
featuresSelected <- grep(".*mean.*|.*std.*", features[,2]) # search for "mean" and "std"
featuresSelected.names <- features[featuresSelected,2]
featuresSelected.names = gsub('-mean', 'Mean', featuresSelected.names) # replace "-mean" by "Mean"
featuresSelected.names = gsub('-std', 'Std', featuresSelected.names) # replace "-std" by "Std"
featuresSelected.names <- gsub('[-()]', '', featuresSelected.names) # delete "[-()]"


# Datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresSelected]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresSelected]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge data
Data <- rbind(train, test) # combine rows
colnames(Data) <- c("subject", "activity", featuresSelected.names)

# Convert activities and subjects into factors
Data$activity <- factor(Data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
Data$subject <- as.factor(Data$subject)

Data.melted <- melt(Data, id = c("subject", "activity"))
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)

write.table(Data.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)

