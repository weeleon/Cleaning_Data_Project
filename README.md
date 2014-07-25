Cleaning_Data_Project
=====================

Course project for the Coursera data science module - Getting and cleaning data

The file "run_analysis.R" is a data cleaning script that processes the raw accelerometer
data according to the instructions provided in the project description.

run_analysis.R requires no arguments.

The script initialises a path to a working directory, checks if a tidy data subfolder
already exists within the working directory and creates the subfolder unless one exists.

The script downloads the raw data directly from the web, saves a copy in the working
directory and then calls a system command to unzip the downloaded object.

To locate the mean and standard deviation columns, the features.txt file is searched
using a pair of grep commands matching on the whole words "mean" and "std", together
with literal parentheses. This results in an ordered vector of numbers defining the
columns which contain the measurement of interest.

A vector of column names is therefore taken as a subset of the features file, consisting
only of the descriptions of mean measurements and its associated standard deviations.

In this column naming convention, parentheses and hyphens are removed from the
vector of column names, and all characters are dropped to the lower case.

The test and training data were processed as follows. A subset is taken consisting only
of the mean and standard deviation columns. The vector of standardised column names
created above was then attached as the descriptive column names.

A column of subject identifiers and a column of activity numeric codes were column-
bound to the left of the subset of raw data. Finally both test and trial data were
amalgamated into a single data file using row-based binding.

The file "activity_codes.txt" was used to convert the numeric activity codes
into a textual (English) physical activity description.

Data for a given person performing a given activity was thus collapsed over all persons
and all activities per person into the mean value using the aggregate command in R.
The aggregation was performed on the merged data, then each line was ordered in sequence
of ascending subject code and ascending physical activity description.

The final result is saved as a CSV-formatted file in the tidy data subfolder with the
filename : tidy-MEANS.csv

The script then prints the description of each column in the tidy data file, reading
from left to right, in a file : tidy-ColumnCodeBook.txt

This column code book therefore replaces features.txt in the downloaded archive.

The script saves the date on which the script was executed (hence the download date
of the zipped archive file from the web) in a file : tidy-DownloadDate.txt

The script then removes ALL variables from application memory before exiting. The
cleaned data may only be accessible within the R environment by explicitly re-loading
the saved file from the tidy data subfolder.



Leonard Wee
25 July 2014
Copenhagen, Denmark











