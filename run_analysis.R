#run_analysis.R is a data cleaning script following the instructions
#set out for the Data Cleaning Module project assignment
#
#

#initialise paths to main data location
myWorkingDirectory <- "/Users/lenw/Documents/Coursera_Offline/Data_Science/Data_Cleaning"
setwd(myWorkingDirectory)

#if the "tidied-data" directory does not exist then create it
if (!file.exists("tidy-data")) { dir.create("tidy-data") }

#download and save the required data archives
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","UCI_HAR_Dataset.zip",method="curl")
#record the date of download
dateDownloaded <- date()

#call system command to unpack the zipped archive
system("unzip UCI_HAR_Dataset.zip")

#initialise relative paths to sub-repositories
testBranch <- "./UCI HAR Dataset/test" #relative path to testing data
trainBranch <- "./UCI HAR Dataset/train" #relative path to training data

#determine which columns correspond to mean and std of physiological measurements
setwd(myWorkingDirectory)
features <- read.table("./UCI HAR Dataset/features.txt")

#use regex to pull out line numbers containing 'mean()' and 'std()'
temp1 <- as.numeric(grep("mean\\(\\)",features$V2))
temp2 <- as.numeric(grep("std\\(\\)",features$V2))

#save the ordered line numbers for subsetting the columns from "features"
colIndicesVect <- sort( union(temp1,temp2) )

#use the ordered vector to generate a vector of meaningful column names
colNamesVect <- as.character(features$V2[colIndicesVect])

#for easy reference, drop all "()" and "-" from the column names
colNamesVect <- gsub("\\(\\)", "", colNamesVect)
colNamesVect <- gsub("-", "", colNamesVect)
colNamesVect <- tolower(colNamesVect)

#clean up memory
rm(temp1,temp2)


#---------------------------------------------------------------------
#import main data blocks from test data folder
setwd(myWorkingDirectory) #sets absolute path to working directory
setwd(testBranch) #relative redirect to test data

testMeasurementTable <- read.table("X_test.txt",colClasses="numeric") #do not rename columns

#only extract the required columns
reducedTestTable <- testMeasurementTable[,colIndicesVect]

#assign column names now to the data frame
names(reducedTestTable) <- colNamesVect

#dump the obsolute data from memory
rm(testMeasurementTable)

#check for missing entries
if ( sum(apply(is.na(reducedTestTable),2,sum)) > 0) stop ("Unresolved missing values in X_test.txt")

testActivityCodes <- read.table("y_test.txt",colClasses="character") #physical activity codes in the range 1-6

#check for missing values
if (sum(is.na(testActivityCodes)) > 0) stop ("Unresolved missing values in y_test.txt")

#rename this column to "ActivityCode" to make it human-readable
names(testActivityCodes) <- "ActivityCode"

testSubjectCodes <- read.table("subject_test.txt",colClasses="integer") #volunteer ID codes in the range 1-30

#check for missing values
if (sum(is.na(testSubjectCodes)) > 0) stop ("Unresolved missing values in subject_test.txt")

#rename this column to "SubjectID" to make it human-readable
names(testSubjectCodes) <- "SubjectID"

#attach subject ID and activity code to the left of each data block
dataA <- cbind(testSubjectCodes,testActivityCodes,reducedTestTable)
rm(testSubjectCodes,testActivityCodes,reducedTestTable)



#---------------------------------------------------------------------
#import main data blocks from training data folder
setwd(myWorkingDirectory) #sets absolute path to working directory
setwd(trainBranch) #relative redirect to test data

trainMeasurementTable <- read.table("X_train.txt",colClasses="numeric") #do not rename columns

#only extract the required columns
reducedTrainTable <- trainMeasurementTable[,colIndicesVect]

#assign column names now to the data frame
names(reducedTrainTable) <- colNamesVect

#dump the obsolute data from memory
rm(trainMeasurementTable)

#check for missing entries
if ( sum(apply(is.na(reducedTrainTable),2,sum)) > 0) stop ("Unresolved missing values in X_train.txt")

trainActivityCodes <- read.table("y_train.txt",colClasses="character") #physical activity codes in the range 1-6

#check for missing values
if (sum(is.na(trainActivityCodes)) > 0) stop ("Unresolved missing values in y_train.txt")

#rename this column to "ActivityCode" to make it human-readable
names(trainActivityCodes) <- "ActivityCode"

trainSubjectCodes <- read.table("subject_train.txt",colClasses="integer") #volunteer ID codes in the range 1-30

#check for missing values
if (sum(is.na(trainSubjectCodes)) > 0) stop ("Unresolved missing values in subject_train.txt")

#rename this column to "SubjectID" to make it human-readable
names(trainSubjectCodes) <- "SubjectID"

#attach subject ID and activity code to the left of each data block
dataB <- cbind(trainSubjectCodes,trainActivityCodes,reducedTrainTable)
rm(trainSubjectCodes,trainActivityCodes,reducedTrainTable)


#---------------------------------------------------------------------
#concatenating the main data blocks
bigDataBlock <- rbind(dataA,dataB)

#order the merged data in order of ascending subject ID then ascending activity code
tidyData1 <- bigDataBlock[order(bigDataBlock$SubjectID,bigDataBlock$ActivityCode),]
rm(dataA,dataB,bigDataBlock)


#---------------------------------------------------------------------
#recoding the activity levels with human-readable descriptions
setwd(myWorkingDirectory)
setwd("./UCI HAR Dataset")

#read in the required text descriptions
ActivityLabels <- read.table("activity_labels.txt",colClasses="character")[,2]

#recoding the activities
temp <- tidyData1$ActivityCode
temp <- gsub("1",ActivityLabels[1],temp)
temp <- gsub("2",ActivityLabels[2],temp)
temp <- gsub("3",ActivityLabels[3],temp)
temp <- gsub("4",ActivityLabels[4],temp)
temp <- gsub("5",ActivityLabels[5],temp)
temp <- gsub("6",ActivityLabels[6],temp)

#pushing the result back into the data table
tidyData1$ActivityCode <- temp

#reset the name of this variable as the "PhysicalActivity"
names(tidyData1)[2] <- "PhysicalActivity"

#free up memory
rm(temp)


#---------------------------------------------------------------------
#drop the cleaned raw data into a file called "tidy-1.csv" in the tidy data folder
setwd(myWorkingDirectory)
setwd("./tidy-data")
write.csv(tidyData1,file="tidy-1.csv", row.names=FALSE)


#---------------------------------------------------------------------
#aggregate the data frame using two factors : first, the activity and then, the subject ID
collapsedData <- aggregate(tidyData1[,c(3:68)],by=list(tidyData1$PhysicalActivity,tidyData1$SubjectID),mean)

#aggregation results in a change of the column name; reset this -
names(collapsedData)[1] <- "PhysicalActivity"
names(collapsedData)[2] <- "SubjectID"

#re-order the data by subject ID and physical activity
tidyData2 <- collapsedData[order(collapsedData$SubjectID,collapsedData$PhysicalActivity),]

#reclaim memory
rm(collapsedData)


#---------------------------------------------------------------------
#drop the cleaned collapsed data into a file called "tidy-MEANS.csv" in the tidy data folder
setwd(myWorkingDirectory)
setwd("./tidy-data")
write.csv(tidyData2,file="tidy-MEANS.csv",row.names=FALSE)

#drop the column names into a file called "tidy-ColumnNames.txt" in the tidy data folder
write.table(names(tidyData2),file="tidy-ColumnNames.txt",col.names=F,row.names=F,quote=F)

#drop the download date into a file called "tidy-DownloadDate.txt" in the tidy data folder
write.table(dateDownloaded,file="tidy-DownloadDate.txt",col.names=F,row.names=F,quote=F)


#---------------------------------------------------------------------
#as the script exits, remove all the internal variables
rm(list=ls())


