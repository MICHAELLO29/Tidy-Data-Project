# Getting and Cleaning Data Course Project
#
# The purpose of this project is to demonstrate the ability to collect, work with, 
# and clean a data set. The goal is to prepare tidy data that can be used for 
# later analysis.

# This script does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with 
#    the average of each variable for each activity and each subject.

##########################################################################################
# 0. SETUP: Download data, load libraries, and read initial files
##########################################################################################

# Install and load the dplyr package if it's not already installed
if (!require("dplyr")) {
  install.packages("dplyr")
}
library(dplyr)

# Download and unzip the dataset if it doesn't already exist
filename <- "UCI_HAR_Dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Read the data files into R
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")


##########################################################################################
# 1. Merges the training and the test sets to create one data set.
##########################################################################################

# Combine the data tables by rows
X_data <- rbind(x_train, x_test)
Y_data <- rbind(y_train, y_test)
Subject_data <- rbind(subject_train, subject_test)

# Combine all three datasets into one single data frame
Merged_Data <- cbind(Subject_data, Y_data, X_data)


##########################################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
##########################################################################################

# Use select() to keep the Subject, code, and any column containing "mean" or "std"
TidyData <- Merged_Data %>% 
  select(Subject, code, contains("mean"), contains("std"))


##########################################################################################
# 3. Uses descriptive activity names to name the activities in the data set.
##########################################################################################

# Replace the numeric activity codes with descriptive names from activity_labels
TidyData$code <- activity_labels[TidyData$code, 2]


##########################################################################################
# 4. Appropriately labels the data set with descriptive variable names.
##########################################################################################

# Get the current column names
colNames <- names(TidyData)

# Use gsub() for pattern matching and replacement to make names more descriptive
# Note: This is a multi-step process to improve readability.
colNames <- gsub("^t", "Time", colNames)
colNames <- gsub("^f", "Frequency", colNames)
colNames <- gsub("Acc", "Accelerometer", colNames)
colNames <- gsub("Gyro", "Gyroscope", colNames)
colNames <- gsub("Mag", "Magnitude", colNames)
colNames <- gsub("BodyBody", "Body", colNames) # Corrects a typo in original feature names
colNames <- gsub("\\.mean", "Mean", colNames) # Replaces .mean with Mean
colNames <- gsub("\\.std", "StdDev", colNames) # Replaces .std with StdDev
colNames <- gsub("\\.", "", colNames) # Removes remaining dots
colNames <- gsub("Freq$", "Frequency", colNames) # Appends Frequency where appropriate
colNames <- gsub("code", "Activity", colNames) # Renames the 'code' column to 'Activity'

# Apply the new, descriptive names to the TidyData data frame
names(TidyData) <- colNames


##########################################################################################
# 5. From the data set in step 4, creates a second, independent tidy data set with 
#    the average of each variable for each activity and each subject.
##########################################################################################

# Group the data by Subject and Activity
# Then, use summarise_all() to calculate the mean for every other column
FinalTidyData <- TidyData %>%
  group_by(Subject, Activity) %>%
  summarise_all(mean)

# Write the final tidy data set to a text file
write.table(FinalTidyData, "FinalTidyData.txt", row.name=FALSE)

# Optional: Print a confirmation message to the console
print("Script finished successfully!")
print("The final tidy data set has been saved as 'FinalTidyData.txt'")