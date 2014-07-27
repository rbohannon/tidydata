# File: run_analysis.R
# Purpose: Imports data files for test dataset and training dataset and
#       associated files. Then:
#       1. Merges the training and the test sets to create one data set.
#       2. Extracts only the measurements on the mean and standard deviation
#          for each measurement. 
#       3. Uses descriptive activity names to name the activities in the
#          data set
#       4. Appropriately labels the data set with descriptive variable name. 
#       5. Creates a second, independent tidy data set with the average of
#          each variable for each activity and each subject.
#
# Author: Randy Bohannon
# Date: 2014-07-27

# LIBRARIES
library(reshape2) # for melt() and dcast()


# FUNCTIONS

# ******************************************************************************
# CompileData()
# Purpose: Creates a single dataset from constituent parts
# Args: dataPath - path to dataset
#       labelsPath - path to activity labels for dataset 
#       subjPath - path to subject IDs for dataset
# Returns: data frame
CompileData <- function(dataPath, labelsPath, subjPath) {
        
        # get dataset
        dataset <- read.table(dataPath,
                              header=FALSE)
        
        # get labels for dataset
        dataLabels <- read.table(labelsPath,
                                 header=FALSE,
                                 col.names=c("activityid"))
        
        # get IDs of subjects in dataset
        subjectIDs <- read.table(subjPath,
                                 header=FALSE,
                                 col.names=c("subject"))
        
        # combine all data into a single data frame
        compiledData <- cbind(subjectIDs, dataLabels, dataset)
        
        return(compiledData)
        
} # end CompileData()

# ******************************************************************************
# ExtractStats()
# Purpose: Creates a data frame containing variables for measurements of mean,
#          standard deviation, subject, and activity taken from dataset.
# Args: dataset - dataset from which the variables are extracted
# Returns: data frame
ExtractStats <- function(dataset) {
        
        # get indexes of columns that are measures of mean or standard deviation
        keeps <- grep("-mean[(]|-std[(]", names(dataset))
        
        # extract the measurements on the mean and
        # standard deviation for each measurement
        statsData <- subset(dataset, select=c(subject, activity, keeps))
        
        return(statsData)

} # end ExtractStats()

# ******************************************************************************
# CleanColNames()
# Purpose: Removes punctuation chars from variable names of dataset and
#          renames some variable names to be a little more descriptive
# Args: dataset - dataset which needs variable names cleaned
# Returns: character vector
CleanColNames <- function(dataset){
        
        # remove parens from function names and preceding dash
        names(dataset) <- sub("-mean[(][)]", "Mean", names(dataset), )
        names(dataset) <- sub("-std[(][)]", "StdDev", names(dataset), )
        
        # remove all other dashes
        names(dataset) <- sub("-", "", names(dataset), )
        
        # replace Acc with Accel
        names(dataset) <- sub("Acc", "Accel", names(dataset), )
        
        # replace BodyBody with Body
        names(dataset) <- sub("BodyBody", "Body", names(dataset), )
        
        # replace initial t with Acctimeel
        names(dataset) <- sub("^t", "time", names(dataset), )
        
        # replace initial f with freq
        names(dataset) <- sub("^f", "freq", names(dataset), )
        
        return(names(dataset))
        
} # end CleanColNames()

# ******************************************************************************
# OutputDataset()
# Purpose: Writes tidy dataset to output file
# Args: dataset - dataset to write to file
# Returns: none
OutputDataset <- function(dataset) {
        
        # change working directory
        setwd("./data")
        
        # if we don't already have a tidy directory,
        # create it
        if (!file.exists("tidy")) {
                dir.create("tidy")
        }

        # write dataset to output file
        write.table(tidyData, file="./tidy/tidyData.txt")
        
        # reset working directory
        setwd("../")
        
} # end OutputDataset

# ******************************************************************************




# if we don't already have a data directory,
# create it
if (!file.exists("data")) {
        dir.create("data")
}

# if we don't already have the data file,
# download it and unzip it
if (!file.exists("./data/UCI_HAR_Dataset.zip")) {
        
        print("Fetching data from source...")
        
        url <- paste0("https://d396qusza40orc.cloudfront.net/",
                      "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
        
        download.file(url,
                      "./data/UCI_HAR_Dataset.zip", 
                      "curl", 
                      T)
        
        unzip("./data/UCI_HAR_Dataset.zip", exdir="./data")
}

print("Processing data...")

# get feature names
feature <- read.table("./data/UCI HAR Dataset/features.txt", 
                      header=FALSE, 
                      col.names=c("featureid", "featurename"),
                      stringsAsFactors=FALSE)

# get activity labels
activityLabel <- read.table("./data/UCI HAR Dataset/activity_labels.txt", 
                      header=FALSE, 
                      col.names=c("activityid", "activity"),
                      stringsAsFactors=FALSE)

# set vars for training data files
dataFile <- "./data/UCI HAR Dataset/train/X_train.txt"
labelFile <- "./data/UCI HAR Dataset/train/y_train.txt"
subjectFile <- "./data/UCI HAR Dataset/train/subject_train.txt"

# compile training dataset
dataTraining <- CompileData(dataFile, labelFile, subjectFile)

# set vars for test data files
dataFile <- "./data/UCI HAR Dataset/test/X_test.txt"
labelFile <- "./data/UCI HAR Dataset/test/y_test.txt"
subjectFile <- "./data/UCI HAR Dataset/test/subject_test.txt"

# compile test dataset
dataTest <- CompileData(dataFile, labelFile, subjectFile)

# combine training data and test data into a single data frame
dataAll <- rbind(dataTraining, dataTest)

# rename variables from generic names to feature names
colnames(dataAll) <- c("subject", "activityid", feature$featurename)

# associate activity ID with activity name;
# activityLabel and dataAll are joined on variable 'activityid'
dataAll <- merge(activityLabel, dataAll, sort=FALSE)

# get means and standard deviations
dataMeanStd <- ExtractStats(dataAll)

# clean variable names
names(dataMeanStd) <- CleanColNames(dataMeanStd)

# get names of measurements
measures <- names(dataMeanStd)[3:68]

dataMelt <- melt(dataMeanStd,
                 id=c("subject", "activity"),
                 measure.vars=measures)

# calculate means of variables on subject and activity
tidyData <- dcast(dataMelt, subject + activity ~ variable, mean)

# write tidy dataset to output file
OutputDataset(tidyData)

print("Done.")