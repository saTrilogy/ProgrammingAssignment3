# Human Activity Recognition Assignment

## Experimental data dimensions, metrics, and source files

Experimental, raw data structure is persisted via, essentially, the five dimensions:

1. The metrics were recorded for two experimental groups of subjects - a control group, nominally designated by “trial” and the balance of subjects nominally designated by “test”. Thus, we have a nominal factor, which we refer to as `group`, of two levels - `trial` and `test`, to correlate metrics with experimental groups.
2. Each group subject is identified by an integer code between 1 and 30 so we have an integer dimension. The thrity subjects are distictly allocated between each experimental group, thus, in any `group` collated or summarised data, we retain distinction of each of the experiment's thirty distinct subjects. This dimension we’ll name `subject` as a nominal factor - it is not ordinal since there is no inherent ranking to be implied by the nominal code.
3. For each subject, instruments recorded a measurement based upon a physical state - such as sitting down, walking etc. This is another nominal factor which we will name `activity`. The factor is encoded as an integer in the range 1 through 6, but a file of labels assocaiated with each integer is supplied (`activity_labels.txt`). In collated data we will rather use this alhpnumeric label as the encoded factor.
4. The raw and post-processed data contains values which reflect observations from an accelerometer and gyroscope and derived therefrom. In the raw and post-processed data these metrics are columnar and, in order to attain normalisation, we need to create a nominal factor, which we name `variable` so the associated observation in the normalised data is specific to each of the metrics so parsed from columnar to normalised form.
4. Unfortunately, the raw `variable` factor is encoded as dimension specific in cartesion space via the `x`, `y` and `z` dimensions. Additionally, some evaluated variables are not single-dimension specific. In the latter case we'll accord a factor label `3d` for these values. Given thus the nominal levels of a `dimension` facor, named accordingly, in normalising the data we split the encoded `variable` levels into `variable` by `dimension` values.  Two instruments were used to record subject activity - an acceleromter and a gyroscope.

Raw measurements per `group` have been split into two sets of files in subdirectories (named *Inertial Signals*) whose parent directory name corresponds to the factor levels of `test` and `train`. These signals have been post-processed and presented in a flat file of each factor level directory named *X_train.txt* and *X_test.txt* respectively. Post-processing includes the evaluation of descriptive statistics for intertial readings as well as a variety of non-single dimensionally specific values which relate, for example to energy evaluations in 3D space - as specified poreviously, we associate such observations with the `dimension` level of `3d`. 

The post processed *X_*`group`*.txt* files each contain 561 metrics and a descriptive label is present in the `group` level file named *features.txt* for each of these metrics. The descriptive labels are not, as they stand, suitable for use in naming columns of loaded data. Associated with each of the *X_*`group`*.txt* files are the files:

1. *subject_test.txt* which encapulates, for each of the rows in this flat file, the value of the `id` factor (the experimental subject identifier).
2. *y_*`group`*.txt* which encapsulates, for each of the rows in this flat file, the value of the `state` factor for which readings were made.

Each of the `group` associated file sets of *X_*`group`*.txt*, *y_*`group`*.txt* and *subject_test.txt* are flat files with space-delimited data. Matching of the factor values for `state` and `id` is via the line number of each file and all files have the same number of lines.

Ultimately, output will consist of a single normalised table with each of the factors (dimensions) appearing as a column under which key we collate a number of metrics from *X_*`group`*.txt* relating to mean and standard deviation evaluations for each `dimension` factor level, in addition to an aggregate table in which we have grouped data by several of the dimensions.

## Data Extraction, Loading and Transformation (ELT)
The process is broken down into a number of steps and encoded in the accompanying script **run_analysis.R** with a significant number of embedded comments. In essence the scipt has the following features and process flow:

1. The working directory is expected to contain the source files of experimental data and the grouped `test` and `train` subdirectories.
2. We make extensive use of `dplyr` functionality and data tables, hence these libraries are referenced and it is pre-supposed that the appropriate packages are installed.
3. We then enumerate, as variables:
   - The target file names (within the working directory and its subdirectories) which are required to be accessible.
   - The majority of the error and informational strings used in reporting the ELT progression through the script.
4. We encode a number of helper functions:
   - `doTry` - A function to test state encapuslated in a try/catch expression. The argument test can be a logical expression or a value - generally a function is a value so the argument may be a function invocation.
   - `fileValidate` - Tests for the existence of a file.
   - `fileLoad` - Makes use of `fread` to load a file into a `data.table`.
   - `fileParse` - A wrapper that given a target file path/name, validates the existence of a file and loads it given the prior supporting functions.
   - `normalise` - In this context the function transforms an arbitrary string (using regular expressions) into a format that is deemed 'acceptable' as a factor label or column name.
5. Thence we ouput a message signifying the start of the ELT process and information regarding the approximate memory estimate (RAM) required to process the files based upon their file size.
6. We then undertake four consecutive steps in the ELT process:
   - **Step 0**: *Construction of label vectors to be used for factor labels and column names*. We hard-code the experimantal group factor labels, parse and process the activity labels file and then hard-code the `dimension` labels.
   - **Step 1**: *Parse and normalise the experiment metrics*. We parse the control file which contains the 561 metric descriptions. Recall that in the file of post-processed observations all of the metrics are denormalised - they are in columnar format. From this file e create a table of name-normalised labels that we may use to assign factor lables for what will become the `variable` dimension and the associated `dimension` label.
   - **Step 2**: *Parse and clean each group factor level's flat files into a single table*. We parse the post-processed metrics file alongside the files that detail the `subject` and `activity` data; all these files should have the same row count as matching relies not on a join, but a direct correlation based upon the row-number per file. Becuase of that, we can simply append vectors into a data table bypassing any need for a join. In data table generation we also pre-pend the `group` label according to which file set we are processing. Each group is processed in turn via a `for` loop and the output consists of a list of data tables - one per `group` label. Fianlly, we use `rbind` to collate the list elements into a single data table.
   - **Step 3**: *Normalise the collated data table*. Given a single table comprising all `group`-related data, we then use `melt` to normalise the `variable` levels and then append a `dimension` column. We can then assign the `dimension` value (execute using a `mutate`) based upon the `variable` value and thence modify the `variable` value as a 'tidy-data' conrmant name. This single, normalised data table is persisted via the variable named `output`. We additionaly undertake a `group_by %>% summarise` to produce another peristed table named `grouped` containing the aggregated, mean metric values based upon the composite dimension key of `subject`, `activity` and  `variable`.

The essential outputs of the ELT process are therefore the variables `output` and `grouped` - for both of which we invoke a `View` to permit data inspection. 

In the final part of the script is code to generate codebooks for each of our output variables. The `datamaid` package is used and its default output is that of a PDF file. Manual porst-processing is required to render Markdown-specific output from the generated `Rmd` files and we have thus also created the single markdown file **CodeBook.md** which contains the collated metadata descriptions for the `output` and `grouped` data tables.























