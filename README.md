#Project Description

##Files
1. run&#95;analysis.R
2. codebook.txt

#run&#95;analysis.R
**Description**

run&#95;analysis.R is the only R script file in this project. This script imports the Human Activity Recognition Using Smartphones Data Set from the UCI Machine Learning Repository (<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>) and manipulates the data to produce a tidy dataset.

**Use**

To use run&#95;analysis.R, copy it to your working directory and run it. run&#95;analysis.R requires the  reshape2 package for the melt() and dcast() functions.


**Functionality**

run&#95;analysis.R first checks to see if a subdirectory of the working directory named "data" exists. If not, the script creates it. It then checks for the existence of the data archive file from the UCI Machine Learning Repository (UCI&#95;HAR&#95;Dataset.zip) in the data directory. If the file is not in the directory, it is downloaded and unzipped to the data directory.

When the archive data is ready, the script imports data from several different files into separate data frames and processes the data.

1. "featureid" and "featurename" are imported from features.txt into data frame feature.

2. "activityid" and "activity" are imported from activity_labels.txt into data.frame activityLabel.

3. Variables dataFile, labelFile, and subjectFile are set to the file paths for the training data, training labels, and training subjects respectively then passed to function CompileData(). CompileData() imports the data from the specified files and binds them into a single data frame. The data frame is returned to the variable dataTraining .

4. The same process is repeated for the test dataset which is saved in the variable dataTest.

5. dataTraining and dataTest are then bound into a single data frame named dataAll.

6. The column names of dataAll are renamed from their generic V1, V2, and such to the variable names saved in the data frame feature (feature$featurename).

7. The data frame activityLabel is then merged with dataAll implicitly joined on the variable activityid.

8. A new data frame named dataMeanStd is created by extracting from dataAll the subject, activity, and all variables that are a mean or a standard deviation of a measurement.
  * I choose to exclude variables that were named like "...-meanFreq()". The document features&#95;info.txt describes these as a weighted average of the frequency, and as such they don't seem to be measurements that are analogous to the other means.

9. The column names of dataMeanStd are "cleaned".
 * Punctuation (dashes and parantheses) are removed.
  * "mean" is replaced with "Mean", and "std" is replaced with "StdDev".
  * "Acc" is replaced with "Accel".
  * The prefix "t" is replaced with "time", and the prefix "f" is replaced with "freq".
  * Instances of "BodyBody" are replaced with "Body".

  Notes:
    * I chose to use camelCase for variable names instead all lower case because I find it easier to read. A variable name should be descriptive enough that the reader can look at it and interpret its meaning quickly. A long name in all lower (or upper) case causes me to read it over more than once to decipher where the word breaks should be to make sense of what it is.

  * I also chose to not drastically rename the variables. There was a lot of discussion in the forums about renaming variables by making them strings of whole words rather than abbreviations, as in AgeAtDiagnosis rather than AgeDx. It should be safe to assume the data consumer is familiar enough with the problem domain that simple abbreviations will be understood. Also, as I stated previously, a variable name should be descriptive enough that the reader can look at it and interpret its meaning quickly, but it should be short enough so as not to be unwieldy.

10. dataMeanStd is then reshaped using the melt() function from the reshape2 package and saved into a new variable called dataMelt.

11. Function dcast(), also from the reshape2 package, is then used to create a new data frame, tidyData, which contains the means of all mean and standard deviation measurements for each subject and activity pair.

12. tidyData is written to disk in a file named tidyData.txt
  * This dataset is tidy because it adheres to the Tidy Data priciples.
    * Column headers are variable names, not values.
    * Each column contains only one variable.
    * Variables are stored only in columns, not in rows.
    * There is only one type of observation in the table. To wit, an observation of a subject engaged in an activity.

#codebook.txt

**Description**

<a href="https://github.com/rbohannon/tidydata/blob/master/codebook.txt">codebook.txt</a> contains a description of the data variables contained in tidyData.txt. It lists each variable, its datatype, and a short description of what the variable represents. Where applicable, the set of acceptable values is also included.

##Raw Data

The raw data is the Human Activity Recognition Using Smartphones Data Set from the UCI Machine Learning Repository (<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>).

(from the UCI website)

**Data Set Information**

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING&#95;UPSTAIRS, WALKING&#95;DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

**Attribute Information**

For each record in the dataset it is provided: 

  * Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
  * Triaxial Angular velocity from the gyroscope.
  * A 561-feature vector with time and frequency domain variables. 
  * Its activity label. 
  * An identifier of the subject who carried out the experiment.