## Assignment 1: 
### Additional utility for the FASTA exercises: AT/GC ratio calculation

The AT/GC ratio calculation uses `awk` to count the canonical DNA bases A, T, G and C and calculate the ratio \((A+T)/(G+C)\). Ambiguous nucleotides, such as N, are excluded from the calculation.

The `bc -l` utility performs decimal division because Bash's built-in arithmetic uses integer arithmetic and would otherwise truncate the fractional part of the result. The `-l` option loads the standard mathematical library and sets the default scale to 20 decimal places.

Both `awk` and `bc` are external utilities that may not be available on every system. Their availability can be checked using:

```bash
command -v awk
command -v bc
```

Further information is available in the [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/gawk.html) and the [GNU bc manual](https://www.gnu.org/software/bc/manual/).


## Assignment 2: 
### Silwood Trees - Data validation and cleaning 
This exercise focuses on validating and cleaning ecological tree-record data using Python. The script, clean_silwoods.py, processes the raw tree dataset and checks data quality, including required fields, record ID formats, valid locations and taxa, numerical ranges, and duplicate records. Validation rules are applied systematically (using the requirements detailed in the metadata) to distinguish vlaid records from those requiring rejection or further investigation. The workflow preserves the original raw data and produces a cleaned dataset alongside records flagged for validation issues, making the cleaning process transparent and reproducible. A summary of oak reocrds by species is also generated to demonstrate how validated ecological data can be used for further analysis. 

## Assignment 3: 
### Tree Heights - Calculate tree heights
This exercise uses R to calculate tree heights from field measurements. The script reads the input data from trees.csv, calculates height using the measured distance and angle of elevation, and writes the results to results/TreeHts.csv. The calcualtion uses the tangent of the angle converted from degrees to radians. 
The exercise develops skills in importing CSV data, performing mathematical trnasformations, writing results to a file, and creatig a reproducible analysis workflow in R. 

### Tree Heights - generalise the tree-height script 
This exercise uses a shell script to retrieve or process the use of command-line tools and shell scripting to automate data processing, apply calculations to measurements, and organise the resulting outputs. It provides practice in working with file paths, processing structured data and producing results reproducibly from the command line. 

### Pound Hill practical - ecololgical data wrangling and analysis 
This exercise explores ecological species-count data from the Pound Hill practical using R. The workflow imports the raw data and accompanying metadata, reshapes the dataset from wide to long format, and validates species counts and sampling identifiers. Blank species-count cells are interpreted as zero only where supported by the dataset's metadata and recording conventions. The analysis calcualtes species richness (the number of species present) and total abundance (the number of individuals) at quadrat level, then calculates mean richness and abundance for each plot. The results are used to compare three cultivation treatments - October, May and March, through summary tables and figures showing indvidual plot-level values and variation among plots. The workflow uses `dplyr`, `tydiyr` and `ggplot2` and is designed to be reproducible without modifying the raw input files. 