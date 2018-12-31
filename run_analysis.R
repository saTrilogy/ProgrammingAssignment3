###############################################################################
# Procedural steps in loading Human Activity Recognition
#
# Author: Chris Shattock
# Date: 2018-12-29
# Licence: Don't care.
#

#setwd("Q:/JHU Data Science/03 Getting and Cleaning Data/Week-04/Assignment")
library(data.table)
library(dplyr)

#### Constants ################################################################
# Constants...
# File path and name for activity labels
activityLabelsFile <- "activity_labels.txt"
# File name with row-matching subject ids. Used with sprintf to
# replace %s with group label.
subjectIdFile <- "%1$s/subject_%1$s.txt"
# File name with activity-matching codes. Used with sprintf to
# replace %s with group label.
activityIdFile <- "%1$s/y_%1$s.txt"
# Metrics file. Used with sprintf to replace %s with group label.
metricsFile <- "%1$s/X_%1$s.txt"
# Column names basis file for metrics (561 columns)
metricColDesc <- "features.txt"


#### Messages #################################################################
m_MemUsage <- "Loading these files will require approximately %.3f GB RAM."
m_Pause <- "Press the [Enter] key to continue the procedure or [Esc] to quit."
m_TestFalse <- "\tYour logical test returned false."
m_NoActivityFile <- "\t\tFailed to find the activity labels file %s"
m_ActivityFileOK <- "\t\tActivity labels file present. Loading..."
m_ActivityLoadOK <- "\t\tSuccessfully loaded activity file."
m_ActivityLoadFail <- "\t\tFailed to load activity file."
m_ActivityLoadParse <- "\t\tParsing activities into factors..."
m_NometricColFile <- "\\ttFailed to find the metric column descriptions file %s"
m_metricColFileOK <- "\t\tMetric column descriptions file present. Loading..."
m_metricColLoadOK <- "\t\tSuccessfully loaded metric column descriptions file."
m_metricColLoadFail <- "\t\tFailed to load metric column descriptions file."
m_Step0 <- "Step 0: Create factors and column name vectors:"
m_Step0Complete <- "        Complete."
m_FactorGroup <- "\tCreating group factors"
m_FactorActivity <- "\tCreating activity factors..."
m_FactorDimension <- "\tCreating dimension factors..."
m_Step1 <- "Step 1: Parse and normalise the experiment metrics:"
m_metricsColumnSubset <- "\t\tFiltering names of metrics to use in ultimate output"
m_metricColFiltered <- "\t\t%.0f Metric column names normalised and filtered for means and std. dev."
m_Step1Complete <- "        Completed characteristing metric names."
m_Step2 <- "Step 2: Parse and clean each group factor level's flat files into a single table"
m_Step2Complete <- "        Completed collating data files"
m_Step2a <- "\tParsing and collated data for experimental group '%s'..."
m_Step2aComplete <- "\tCompleted table construction for experimental group '%s'..."
m_GroupFileLoad <- "\tLoading group '%s' files..."
m_GroupFileVerifyOK <- "\t\tSuccessfully located file %s."
m_GroupFileVerifyFail <- "\t\tFailed to locate file %s."
m_GroupFileLoadOK <- "\t\tSuccessfully parsed file %s."
m_GroupFileLoadFail <- "\t\tFailed to parse file %s."
m_groupConcat <- "\tConcatenating group tables into a single table."
m_GroupFileParseComplete <- "        Completed parsing all files into group-based tables."
m_Step3 <- "Step 3: Normalise the collated data table"
m_Normalise <- "\tNormalising the group-appended data table..."
m_GroupBy <- "\tGrouping data by subject, activity and variable..."
m_Step3Complete <- "        Completed normalisation"
m_Rowcount <- "(Row count = %5d)"
m_Codebook <- "Press the [Enter] key to create codebooks or [Esc] to quit."

#### Try/Catch ################################################################
# A function to test state encapuslated in a try/catch expression
# The argument test can be a logical expression or a value - generally
# a function is a value so the argument may be a function invocation.
doTry <- function(test,failMsg = NULL) {
  # List to maintain error status condition.
  state <- FALSE
  msg <- NULL
  val <- NULL
  # Evaluate the test and assign to output State.
  tryCatch(
    # 'try' the test
    state <-
      if(class(test)[1] == "logical") {
        # The result of a logical test
        b <- test
        # If the logical test failed we have an
        # undified FALSE state so use the parsed msg
        # to qualify the message or, if null, provide
        # a default message
        if (!b) {
         msg <- 
          if(is.null(failMsg)){
            m_TestFalse
          } else {
            failMsg
          }
        } 
        # Output the result of a logical test
        b 
      } else {
       # For anything that is not a logical test, then
       # just execute the argument expression.
       val <- eval(test)
       TRUE } 
    # If try results in an error...
    ,error=function(exc) {
      # Persist the error message
      msg <- sprintf("Error raised of %s",exc)
      # Output a logical State of FALSE
      state <- FALSE }
    # If try results in a warning...
    ,warning=function(exc) {
      # Persist the warning message
      msg <- sprintf("Warning raised of %s",exc)
      # Output a logical State of FALSE - we consider a warning
      # to be as terminal as an error.
      state <- FALSE }
    # Omit the finally for the try/catch
  )
  # Output the computed status list.
  list("State" = state, "Message" = msg, "Value" = val)
}

#### File Validate ############################################################
# Wrapper for validation of file existence
# Arguments: 1. fn - the target file path and name
#            2. msgOK - message to show for validation success
#            3. msgFail - message to show for validation failure
fileValidate <- function(fn, msgOK, msgFail){
  # Validate existence of activity labels file
  isValid <- doTry(file.exists(fn),
                   if(grepl("%s", msgFail, fixed = TRUE)){
                     sprintf(msgFail, fn)
                    } else {
                      msgFail
                    })
  
  if (!isValid$State) {
    stop(isValid$Message)
  } else {
    if(grepl("%s", msgOK, fixed = TRUE)){
      sprintf(msgOK, fn)
    } else {
      msgOK
    }
  }  
}

#### File Loader ##############################################################
# Use fread to read a file into a data table
# Arguments: 1. fn - the name of the file to load
#            2. cNameVec (optional) - if specificed a character vector
#               of column names to be used.
# Output is a data table.
fileLoad <- function(fn, cNameVec = vector()){
  if(length(cNameVec) > 0) {
    data.table(fread(fn, col.names = cNameVec,
                     header = FALSE, strip.white = TRUE, 
                     blank.lines.skip = TRUE, check.names = FALSE, 
                     key = NULL, stringsAsFactors = FALSE))
  } else {
    data.table(fread(fn,
                     header = FALSE, strip.white = TRUE, 
                     blank.lines.skip = TRUE, check.names = FALSE, 
                     key = NULL, stringsAsFactors = FALSE))
  }
}


#### File Parse ###############################################################
# Uses, in turn fileVerify and fileLoad functions to attempt to load a file
fileParse <- function(fn, msgVerifyOK, msgVerifyFail, 
                          msgLoadOK, msgLoadFail, ...){
  fileValidate(fn, msgVerifyOK, msgVerifyFail)
  isValid <- doTry(fileLoad(fn, ...), 
                   if(grepl("%s", msgLoadFail, fixed = TRUE)){
                     sprintf(msgLoadFail, fn)
                   } else {
                     msgLoadFail
                   } )
  if (!isValid$State) stop(isValid$Message)
  message(
    paste(
      if(grepl("%s", msgLoadFail, fixed = TRUE)){
        sprintf(msgLoadOK, fn)
      } else {
        msgLoadOK
      },
    sprintf(m_Rowcount, nrow(isValid$Value))) )
  isValid$Value
}

#### Normalise Name ###########################################################
# For a character string get rid of non-alphanumeric characters and lower-case
# so output is suitable as a label or column name
# Arguments: 1. s - the string to normalise
# Output is a normalised string.
normalise <- function(s){
  tolower(
    gsub("[^a-zA-z0-9*]|_", "", s)
  )
}

#### Working Direrctory #######################################################
# We pressume that the assignment script and files
# are all in a subdriectory named "Assignment". Do this interactively...
#setwd(paste(getwd()[1], "/Assignment", sep=""))
message("Working directory = ", getwd()[1])

#### Working Memory ###########################################################
# Estimate and output ram requirement...
message(sprintf(m_MemUsage,
                sz <- round( ( file.info(activityLabelsFile)$size +
                        file.info(sprintf(subjectIdFile, "test"))$size +
                        file.info(sprintf(subjectIdFile, "train"))$size +
                        file.info(sprintf(activityIdFile, "test"))$size +
                        file.info(sprintf(activityIdFile, "train"))$size +
                        file.info(sprintf(metricsFile, "test"))$size +
                        file.info(sprintf(metricsFile, "train"))$size +
                        file.info(metricColDesc)$size ) / 2^30, 3 ) ) )

#### Step 0 ###################################################################
# Pre-processing to construct label vectors for factors and column names.

message(m_Step0)
# 1. Create the 'top-level' factor for the experimental study groups.
message(m_FactorGroup)
groupLabels <- factor(c("test", "train"))

# Validate and Parse activity labels file
message(m_FactorActivity)
act <-
  fileParse(activityLabelsFile, 
            m_ActivityFileOK, m_NoActivityFile, 
            m_ActivityLoadOK, m_ActivityLoadFail,
            c("key", "value"))

# Parse loaded activities as a factor where the labels
# are 'standardised' - that is, eliminate non alphanumeric
# characters and lower-case.
message(m_ActivityLoadParse)
activityLabels <- 
  mutate(act, activity = normalise(act$value)) %>%
  select(key,activity)
# Remove temporary variable
rm(act)

# Create the dimension factor
message(m_FactorDimension)
dimensionLabels <- factor(c("x", "y", "z", "3d"))


message(m_Step0Complete)

#### Step 1 ###################################################################
# Parse and normalise the experiment metrics
message(m_Step1)

# Validate and Parse metric column descriptions file
mcn <-
  fileParse(metricColDesc, 
            m_metricColFileOK, m_NometricColFile, 
            m_metricColLoadOK, m_metricColLoadFail,
            c("key", "value"))

# Firstly, Create the table of filtered column names to use for metrics
message(m_metricsColumnSubset)
metricColNames <- 
  # Filter rows to those only regarding means and std. deviations.
  filter(mcn, grepl("mean|std", value, fixed = FALSE)) %>%
  # Normalise names so may be used as column names.
  mutate(value = normalise(value)) 
# Now work back in the dimension levels into the column names
# for later reference in denormalisation.
for(i in 1: length(metricColNames$key)){ 
  metricColNames$value[i] <-
    switch(substr(metricColNames$value[i], 
                  nchar(metricColNames$value[i]), 
                  nchar(metricColNames$value[i])),
           "x" = sub("[x]$", "_x", metricColNames$value[i]),
           "y" = sub("[y]$", "_y", metricColNames$value[i]),
           "z" = sub("[z]$", "_z", metricColNames$value[i]),
           paste0(metricColNames$value[i],"_3d") 
    ) } 

# For each column name, assocate a factor and dimension for the
# generation of normalised outout
metricColNames <- 
  mutate(metricColNames, dimension="") %>%
  mutate(dimension = sub("(.+_)", "", value), 
         factor = sub("(_x$)|(_y$)|(_z$)|(_3d$)", "", value))

message(sprintf(m_metricColFiltered, length(metricColNames$key)))
# Remove temporary variable
rm(mcn)

message(m_Step1Complete)

#### Step 2 ###################################################################
# Parse and clean each group factor level's flat files into a single table.
message(m_Step2)

# use an initially empty list to collate tables for each group
groupData = list()
# An index for the list used in appending items
listIndex <- 0
# For each group we need to increment the subject id to make them distinct
# and distinguish them across groups.

# Iterate process based upon group factor levels
for(group in levels(groupLabels)){
  message(sprintf(m_Step2a, group))
  message(sprintf(m_GroupFileLoad, group))
  listIndex <- listIndex + 1
  groupData[[listIndex]] <- data.table(
    # Prepend the group dimension
    data.table(rep(group)) %>% rename(group = V1)
    # append the subject id dimension
    ,fileParse(sprintf(subjectIdFile, group), 
               m_GroupFileVerifyOK, m_GroupFileVerifyFail,
               m_GroupFileLoadOK, m_GroupFileLoadFail) %>%
       rename(subject = V1) #%>%
      # We now mutate the subject od based upon the group...
      #mutate(subject = subject + (listIndex - 1) * subjectsPerGroup)
    # Append the activity dimension
    ,fileParse(sprintf(activityIdFile, group), 
               m_GroupFileVerifyOK, m_GroupFileVerifyFail,
               m_GroupFileLoadOK, m_GroupFileLoadFail) %>%
       rename(activity = V1) %>%
       # Mutate the activity id into its associated string
       mutate(activity = activityLabels$activity[activity])
    ,fileParse(sprintf(metricsFile, group), 
               m_GroupFileVerifyOK, m_GroupFileVerifyFail,
               m_GroupFileLoadOK, m_GroupFileLoadFail) %>%
       # Apply our column filter
       select(metricColNames$key) %>%
       # Rename the filtered columns
       rename_all(vars(metricColNames$value))
    ) %>%
    mutate(group = as.factor(group), 
           subject = as.factor(subject), 
           activity = as.factor(activity))  
  message(sprintf(m_Step2aComplete, group))
}
message(m_GroupFileParseComplete)

# Now append the data tables in the list...
message(m_groupConcat)
denormalised <- do.call("rbind", groupData)
# Purge our intermediate tables
rm(groupData)

message(m_Step2Complete)

#### Step 3 ###################################################################
# Normalise the collated data table.
message(m_Step3)

# Normalisation process...
message(m_Normalise)
output <- 
  # Use melt to norlise the non-factors column which, by default
  # will create a variable named column whose content will encoded as
  # a factor of the original column names and the associated measurement
  # will be saved in a column named value.
  melt(denormalised, id.vars = c("group", "subject", "activity")) %>%
  # We add the dimension column and assign its value as the suffix
  # of the original column name - that is, x, y, z or 3d. We then
  # modify the row-encoded factor 'variable' to remove the _x suffix etc.
  mutate(dimension = as.factor(sub("(.+_)", "", variable)), 
         variable = as.factor(sub("(_x$)|(_y$)|(_z$)|(_3d$)", "", variable))
         ) %>%
  # Finallt, re-order the columns...
  select(group, subject, activity, variable, dimension, value)

# Finally, we group by as the assignment requires..
message(m_GroupBy)
grouped <- group_by(output, subject, activity, variable) %>% 
           # In the grouped data we will add a column named mean
           # which is the average value of the detail rows value column
           summarise(mean = mean(value))

message(m_Step3Complete)

# Invoke a view against the detail, normalised data
View(output)
# Invoke a view against the aggregated data
View(grouped)

# Code Book generation
invisible(readline(prompt = m_Codebook))
library(dataMaid)
library(rmarkdown)
# Codebook and attributes for detail data
attr(output$group, "labels") <- 
  "Experiment group - 'test' or 'trial'."
attr(output$group, "shortDescription") <- paste(
  "The experimental design of 30 subjects was split into two groups,",
  "a control/calibration group nominally labeled 'test' and the rest",
  "in the nominally labelled 'trial' group.")
attr(output$subject, "labels") <- 
  "Experimental Subject Identifier"
attr(output$subject, "shortDescription") <- 
  "Each subject is assigned a numeric identifier in the range 1 through 30."
attr(output$activity, "labels") <- 
  "Tracked movement activity"
attr(output$activity, "shortDescription") <- 
  "A range of activities - such as 'walking' for which data were recorded."
attr(output$variable, "labels") <- 
  "Accelerometer and Gyroscope based metric."
attr(output$variable, "shortDescription") <- paste(
  "The raw data collected in each 3D dimension by an accelerometer and",
  "gyroscope whilst the subject was undertaking an activity. Additionally,",
  "some post-processing evaluation (frequency and time domains) which is",
  "not single-simension related but wholsitically relates to an acceleration",
  "vector. Only mean and standard deviation evaluated observables are",
  "persisted in the output.")
attr(output$dimension, "labels") <- "Cartesian dimension"
attr(output$dimension, "shortDescription") <- paste(
  "One of x, y or z where a measurment is so related or, for more",
  "general evalautions, 3d")
attr(output$value, "labels") <- 
  "The numeric value of the recorded measurement"
attr(output$value, "shortDescription") <- paste(
  "All measurements are recorded as a factor of gravitational acceleration",
  "g of approximaely 9.8 metre per second squared.")
makeCodebook(output, file="cb_output.Rmd", 
             replace = TRUE, addSummaryTable = TRUE, 
             codebook = TRUE,  standAlone = TRUE,
             reportTitle = "Codebook for detail data table 'output'")
# Manually edit the .Rmd file and set the output to md_document - then...
#render("cb_output.Rmd")

# Codebook and attributes for grouped data
attr(grouped$subject, "labels") <- 
  "Experimental Subject Identifier"
attr(grouped$subject, "shortDescription") <- 
  "Each subject is assigned a numeric identifier in the range 1 through 30."
attr(grouped$activity, "labels") <- 
  "Tracked movement activity"
attr(output$activity, "shortDescription") <- 
  "A range of activities - such as 'walking' for which data were recorded."
attr(grouped$variable, "labels") <- 
  "Accelerometer and Gyroscope based metric."
attr(grouped$variable, "shortDescription") <- paste(
  "The raw data collected in each 3D dimension by an accelerometer and",
  "gyroscope whilst the subject was undertaking an activity. Additionally,",
  "some post-processing evaluation (frequency and time domains) which is",
  "not single-simension related but wholsitically relates to an acceleration",
  "vector. Only mean and standard deviation evaluated observables are",
  "persisted in the output.")
attr(grouped$mean, "labels") <- "Average of grouped values from output table."
attr(grouped$mean, "shortDescription") <- paste(
  "All measurements are recorded as a factor of gravitational acceleration",
  "g of approximaely 9.8 metre per second squared.")
makeCodebook(grouped, file="cb_grouped.Rmd", 
             replace = TRUE, addSummaryTable = TRUE, 
             codebook = TRUE, standAlone = TRUE, 
             reportTitle = "Codebook for aggregated data table 'grouped'")
# Manually edit the .Rmd file and set the output to md_document - then...
#render("cb_grouped.Rmd")

