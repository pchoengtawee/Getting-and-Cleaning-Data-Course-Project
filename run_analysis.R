rm(list = ls()) # Remove all variables from workspace
getwd() # check where is the working directory
install.packages("reshape2")
library(reshape2)

# Import train text files
features = read.table('./features.txt', header = FALSE);
activity_type = read.table('./activity_labels.txt', header = FALSE);
subject_train = read.table('./train/subject_train.txt', header = FALSE);
x_train = read.table('./train/X_train.txt', header = FALSE);
y_train = read.table('./train/y_train.txt', header = FALSE);
# Import test text files
subject_test = read.table('./test/subject_test.txt', header = FALSE);
x_test = read.table('./test/X_test.txt', header = FALSE);
y_test = read.table('./test/y_test.txt', header = FALSE);

# print data of each table to check raw data

features
activity_type
subject_train
x_train
y_train
subject_test 
x_test
y_test

# create column names for the above tables
colnames(activity_type) = c('Activity_ID','Activity_Type');
colnames(subject_train) = "Subject_ID";
colnames(x_train) = features[,2];
colnames(y_train) = "Activity_ID";
colnames(subject_test) = "Subject_ID";
colnames(x_test) = features[,2];
colnames(y_test) = "Activity_ID";

# Merge the training and test sets to create one data set
TrainRawdata = cbind(subject_train,y_train,x_train);
TestRawdata = cbind(subject_test,y_test,x_test);
All_TrainTest_Data = rbind(TrainRawdata,TestRawdata);

#check merging tables
TrainRawdata
TestRawdata
All_TrainTest_Data

# convert comlumn 2 of features and labels to string
featuresColumn2 <- as.character(features[,2])
activity_type_column2 <-as.character(activity_type[,2])

featuresColumn2
activity_type_column2

#Extract only measurement on the mean and standard deviation for each measurement
SelectedFeatures <- grep(".*mean.*|.*std.*", featuresColumn2) # search for "mean" and "std" 
SelectedFeaturesName <- features[SelectedFeatures,2]
SelectedFeaturesName = gsub('-mean', 'Mean',SelectedFeaturesName)
SelectedFeaturesName = gsub('std', 'Std',SelectedFeaturesName)
SelectedFeaturesName = gsub('[-()]', '',SelectedFeaturesName)

#check search result
SelectedFeatures
SelectedFeaturesName

# Add label to table
colnames(All_TrainTest_Data) <-c("Subject_ID", "Activity_ID", SelectedFeaturesName)

# create a factor
All_TrainTest_Data$Activity_ID <- factor(All_TrainTest_Data$Activity_ID, levels = activity_type[,1], labels = activity_type[,2])
All_TrainTest_Data$Subject_ID <- as.factor(All_TrainTest_Data$Subject_ID)

All_TrainTest_Data.melt <- melt(All_TrainTest_Data, id = c("Subject_ID", "Activity_ID"))
All_TrainTest_Data.mean <- dcast(All_TrainTest_Data.melt,Subject_ID + Activity_ID ~ variable, mean)

#create a new table
write.table(All_TrainTest_Data.mean, "Final_tidy_data", row.names = FALSE, quote = FALSE)

