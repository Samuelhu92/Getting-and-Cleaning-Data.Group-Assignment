#Directory and files
require(plyr)
uci_hard_dir <- "UCI\ HAR\ Dataset"
feature_file <- paste(uci_hard_dir, "/features.txt", sep = "")
activity_labels_file <- paste(uci_hard_dir, "/activity_labels.txt", sep = "")
x_train_file <- paste(uci_hard_dir, "/train/X_train.txt", sep = "")
y_train_file <- paste(uci_hard_dir, "/train/y_train.txt", sep = "")
subject_train_file <- paste(uci_hard_dir, "/train/subject_train.txt", sep = "")
x_test_file  <- paste(uci_hard_dir, "/test/X_test.txt", sep = "")
y_test_file  <- paste(uci_hard_dir, "/test/y_test.txt", sep = "")
subject_test_file <- paste(uci_hard_dir, "/test/subject_test.txt", sep = "")
#load files
features <- read.table(feature_file, colClasses = c("character"))
activity_labels <- read.table(activity_labels_file, col.names = c("ActivityId", "Activity"))
x_train <- read.table(x_train_file)
y_train <- read.table(y_train_file)
subject_train <- read.table(subject_train_file)
x_test <- read.table(x_test_file)
y_test <- read.table(y_test_file)
subject_test <- read.table(subject_test_file)
#merge test and train datasets into a combined one
trainingdata <- cbind(cbind(x_train, subject_train), y_train)
testdata <- cbind(cbind(x_test, subject_test), y_test)
sensordata <- rbind(trainingdata, testdata)
#create labels of new dataset
labels<-rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(sensordata)<-labels
#extract required measurements 
sensordatameanstd <- sensordata[,grepl("mean|std|Subject|ActivityId", names(sensordata))]
#create a factor variables to sort different groups according to ActivityID
sensordatameanstd <- merge(sensordatameanstd, activity_labels, by = "ActivityId", match = "first")
#remove parentheses
names(sensordatameanstd) <- gsub('\\(|\\)',"",names(sensordatameanstd), perl = TRUE)
#make syntactically valid names
names(sensordatameanstd) <- make.names(names(sensordatameanstd))
#make clearer names
names(sensordatameanstd) <- gsub('Acc',"Acceleration",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('GyroJerk',"AngularAcceleration",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('Gyro',"AngularSpeed",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('Mag',"Magnitude",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('^t',"TimeDomain.",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('^f',"FrequencyDomain.",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('\\.mean',".Mean",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('\\.std',".StandardDeviation",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('Freq\\.',"Frequency.",names(sensordatameanstd))
names(sensordatameanstd) <- gsub('Freq$',"Frequency",names(sensordatameanstd))
#create a new dataset with average of each variable for each activity and each subject
sensoravg = ddply(sensordatameanstd, c("Subject","Activity"), numcolwise(mean))
write.table(sensoravg,file="sensoravg.txt",row.names = F)
