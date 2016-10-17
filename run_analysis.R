#  The purpose of this project is to demonstrate your ability to collect, 
#  work with, and clean a data set. The goal is to prepare tidy data that can be
#  used for later analysis. You will be graded by your peers on a series of 
#  yes/no questions related to the project. You will be required to submit: 
#  1) a tidy data set as described below, 
#  2) a link to a Github repository with your script for performing the analysis, and 
#  3) a code book that describes the variables, the data, and any 
#  transformations or work that you performed to clean up the data called 
#  CodeBook.md. You should also include a README.md in the repo with your 
#  scripts. This repo explains how all of the scripts work and how they are connected.
#
#  One of the most exciting areas in all of data science right now is wearable 
#  computing - see for example this article . Companies like Fitbit, Nike, and 
#  Jawbone Up are racing to develop the most advanced algorithms to attract new 
#  users. The data linked to from the course website represent data collected 
#  from the accelerometers from the Samsung Galaxy S smartphone. A full 
#  description is available at the site where the data was obtained:
#        
#        http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
#  Here are the data for the project:
#        
#        https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
#  You should create one R script called run_analysis.R that does the following.
#
#  Merges the training and the test sets to create one data set.
#  Extracts only the measurements on the mean and standard deviation for each measurement.
#  Uses descriptive activity names to name the activities in the data set
#  Appropriately labels the data set with descriptive variable names.
#  From the data set in step 4, creates a second, independent tidy data set with
#  the average of each variable for each activity and each subject.

rm(list=ls())

#  Read in the data files. 
xTest = read.table("../UCI HAR Dataset/test/X_test.txt", header=FALSE)
yTest = read.table("../UCI HAR Dataset/test/y_test.txt", header=FALSE)
subjectTest = read.table("../UCI HAR Dataset/test/subject_test.txt", header=FALSE)

xTrain = read.table("../UCI HAR Dataset/train/X_train.txt", header=FALSE)
yTrain = read.table("../UCI HAR Dataset/train/y_train.txt", header=FALSE)
subjectTrain = read.table("../UCI HAR Dataset/train/subject_train.txt", header=FALSE)

#  To explore these various pieces of data read in, use dim().
#  Here's what I found:
#       xTest:          2947 rows and 561 columns
#       yTest:          2947 rows and 1 column
#       subjectTest:    2947 rows and 1 column
#       xTrain:         7352 rows and 561 columns
#       yTrain:         7352 rows and 1 column
#       subjectTrain:   7352 rows and 1 column

dim(xTest)
dim(yTest)
dim(subjectTest)
dim(xTrain)
dim(yTrain)
dim(subjectTrain)

#  Now, merge the test and train sets, per the requirements.
xData = rbind(xTest, xTrain)
yData = rbind(yTest, yTrain)
subjectData = rbind(subjectTest, subjectTrain)

#  Results?  Using dim() again, I find:
#  xData:       10299 rows and 561 columns
#  yData:       10299 rows and 1   column
#  subjectData: 10299 rows and 1   column
dim(xData)
dim(yData)
dim(subjectData)

#  Now, we can pull all the data together -- subjectData is the subject each
#  instance is associated with, yData is the activity that each instance is
#  associate with, and then the data itself, which is xData
allData = cbind(subjectData, yData, xData)

#  But what is this stuff?  Now, associate names with the rows
#  and columns.
#  features has 1 column and 561 rows.  These are the names of the columns for 
#  xData.  Note that features.txt is the same file for the test and train sets.
features = read.table("../UCI HAR Dataset/features.txt", header=FALSE)
dim(features)  #  561, 2 -- a column number and a column name

xDataColNames = as.character(features[,2])
names(allData) = c("subject", "activity", xDataColNames)

#  We can actually associate more descriptive names to activity, so do that now.
al = read.table("../UCI HAR Dataset/activity_labels.txt", header=FALSE, 
                col.names = c("activityNumber", "activityName"))
activityLabels = factor(al$activityName)

fromLabels = sort(unique(allData$activity))
allData$activity <- factor(allData$activity,
                           levels = fromLabels,
                           labels = activityLabels)

#  At this point, everything has been merged and named.  Now, subset only
#  the mean and standard deviation (std) data from the overall data set, but
#  add back in the subject and activity, which are the "keys".
meanstdColumns = grepl("[Mm][Ee][Aa][Nn]|[Ss][Tt][Dd]", names(allData))
subsetDataColumns = c("subject", "activity", names(allData)[meanstdColumns])
meanstdSubset = allData[,subsetDataColumns]
dim(meanstdSubset)

#  The last requirement is to create an independent tidy data set with
#  the average of each variable for each activity and each subject.
install.packages("dplyr")
library(dplyr)
groupedMeanStdData <- group_by(meanstdSubset, subject, activity)
averagedMSD<-summarize_each(groupedMeanStdData, funs(mean))
dim(averagedMSD)
write.csv(averagedMSD, "Project_means.csv", row.names=FALSE)

