#library to load
library(plyr)
library(dplyr)
library(stringr)


# read train data
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
id_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# read test data
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
id_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# read data description
variable_names <- read.table("./UCI HAR Dataset/features.txt")

# read activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

#Merge database
x_total <- rbind(x_train, x_test)
y_total <- rbind(y_train, y_test)
id_total <- rbind(id_train, id_test)


#Extracts only the measurements on the mean and standard deviation for each measurement.
select_col <- grep("mean\\(\\)|std\\(\\)", variable_names$V2)
x_total <- select(x_total, select_col)

#Appropriately labels the data set with descriptive variable names.
colnames(x_total) <- variable_names[select_col,2]

col_names <- variable_names[select_col,2]

col_names <- gsub("\\()","",col_names)
col_names <- gsub("-std","-StdDev",col_names)
col_names <- gsub("-mean","-Mean",col_names)
col_names <- gsub("^(t)","time-",col_names)
col_names <- gsub("^(f)","freq-",col_names)
        
colnames(x_total) <- col_names

#Uses descriptive activity names to name the activities in the data set
y_total <- join(y_total, activity_labels)

x_total <- cbind(activity = y_total[,2], x_total)

#creates a second, independent tidy data set with the average of each variable for each activity and each subject.
names(id_total)[1] <- paste("subject")
total <- cbind(id_total, x_total)
total_mean <- total %>% group_by(activity, subject) %>% summarise_all(funs(mean))

#Write new tidy dataset
write.table(total_mean, file = "./UCI HAR Dataset/tidydata.txt", row.names = FALSE, col.names = TRUE)
