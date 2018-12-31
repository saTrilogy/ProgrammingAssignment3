# Codebook for detail data table 'output'

## Data report overview
The dataset has the following dimensions:

| Feature        | Result |
|----------------|-------:|
|Number of observations | 813621|
|Number of variables    | 6|

## Codebook summary table

|Label|Variable|Class|# unique values|Missing|Description|
|-----|--------|-----|-------:|:-------:|----------------|
|Experiment group - 'test' or 'trial'.|**group**|factor|2|0.00 %|The experimental design of 30 subjects was split into two groups, a control/calibration group nominally labeled 'test' and the rest in the nominally labelled 'trial' group.|
|Experimental Subject Identifier|**subject**|factor|30|0.00 %|Each subject is assigned a numeric identifier in the range 1 through 30.
|Tracked movement activity|**activity**|factor|6|0.00 %|A range of activities - such as 'walking' for which data were recorded.
|Accelerometer and Gyroscope based metric.|**variable**|factor|41|0.00 %|The raw data collected in each 3D dimension by an accelerometer and gyroscope whilst the subject was undertaking an activity. Additionally, some post-processing evaluation (frequency and time domains) which is not single-simension related but wholsitically relates to an acceleration vector. Only mean and standard deviation evaluated observables are persisted in the output.
|Cartesian dimension|**dimension**|factor|4|0.00 %|One of x, y or z where a measurment is so related or, for more general evalautions, 3d
|The numeric value of the recorded measurement|**value**|numeric|783226|0.00 %|All measurements are recorded as a factor of gravitational acceleration g of approximaely 9.8 metre per second squared.

## Variable list

### group
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|2|
|Mode|"train"|

### subject
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|30|
|Mode|"25"|

### activity
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|6|
|Mode|"laying"|

### variable
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|41|
|Mode|"fbodyaccjerkmean"|

### dimension
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|4|
|Mode|"3d"|

### value
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|783226|
|Median|-0.4|
|1st and 3rd quartiles|-0.97; -0.04|
|Min. and max.|-1; 1|

## Report generation information:

-   Created by Chris M. Shattock (username: `Chris`).

-   Report creation time: Mon Dec 31 2018 02:24:03

-   Report Was run from directory:
    `Q:/JHU Data Science/03 Getting and Cleaning Data/Week-04/Assignment`

-   dataMaid v1.1.2 \[Pkg: 2018-05-03 from CRAN (R 3.5.1)\]

-   R version 3.5.1 (2018-07-02).

-   Platform: x86\_64-w64-mingw32/x64 (64-bit)(Windows &gt;= 8 x64
    (build 9200)).

-   Function call:
    `makeDataReport(data = output, mode = "summarize", file = "cb_output.Rmd",  replace = TRUE, standAlone = TRUE, checks = list(list("showAllFactorLevels")),  listChecks = FALSE, maxProbVals = FALSE, addSummaryTable = TRUE,  codebook = TRUE, reportTitle = "Codebook for detail data table 'output'")`
***
# Codebook for aggregated data table 'grouped'

## Data report overview
The dataset examined has the following dimensions:

| Feature        | Result |
|----------------|-------:|
|Number of observations | 7380|
|Number of variables    | 4|

## Codebook summary table
|Label|Variable|Class|# unique values|Missing|Description|
|-----|--------|-----|-------:|:-------:|----------------|
|Experimental Subject Identifier|**subject**|factor|30|0.00 %|Each subject is assigned a numeric identifier in the range 1 through 30.
|Tracked movement activity|**activity**|factor|6|0.00 %|A range of activities - such as 'walking' for which data were recorded.
|Accelerometer and Gyroscope based metric.|**variable**|factor|41|0.00 %|The raw data collected in each 3D dimension by an accelerometer and gyroscope whilst the subject was undertaking an activity. Additionally, some post-processing evaluation (frequency and time domains) which is not single-simension related but wholsitically relates to an acceleration vector. Only mean and standard deviation evaluated observables are persisted in the output.
|Average of grouped values from output table.|**value**|numeric|7020|0.00 %|All measurements are recorded as a factor of gravitational acceleration g of approximaely 9.8 metre per second squared.

## Variable list

### subject
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|30|
|Mode|"2"|

### activity
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|6|
|Mode|"laying"|

### variable
| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|41|
|Mode|"fbodyaccjerkmean"|


### mean

| Feature        | Result |
|----------------|-------:|
|Variable type | factor|
|Number of missing obs.|0 (0 %)|
|Number of unique values|7020|
|Median|-0.38|
|1st and 3rd quartiles|-0.96; -0.03|
|Min. and max.|-1; 0.64|

## Report generation information:

-   Created by Chris M. Shattock (username: `Chris`).

-   Report creation time: Mon Dec 31 2018 02:24:11

-   Report Was run from directory:
    `Q:/JHU Data Science/03 Getting and Cleaning Data/Week-04/Assignment`

-   dataMaid v1.1.2 \[Pkg: 2018-05-03 from CRAN (R 3.5.1)\]

-   R version 3.5.1 (2018-07-02).

-   Platform: x86\_64-w64-mingw32/x64 (64-bit)(Windows &gt;= 8 x64
    (build 9200)).

-   Function call:
    `makeDataReport(data = grouped, mode = "summarize", file = "cb_grouped.Rmd",  replace = TRUE, standAlone = TRUE, checks = list(list("showAllFactorLevels")),  listChecks = FALSE, maxProbVals = FALSE, addSummaryTable = TRUE,  codebook = TRUE, reportTitle = "Codebook for aggregated data table 'grouped'")`
