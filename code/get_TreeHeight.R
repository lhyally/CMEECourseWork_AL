# code/get_TreeHeight.R

# 1. Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
    stop(
        "No input file supplied. Usage: ",
        "Rscript code/get_TreeHeight.R <input.csv>",
        call. = FALSE
    )
}

if (length(args) != 1) {
stop(
    "Expeceted exactly one CSV path argument.",
    call. = FALSE
    )
}

input_path <- args[1]

#2. Check that the input file exists and its readable
if (!file.exists(input_path) || dir.exists(input_path)) {
    stop("Input file does not exist: ", input_path, call. = FALSE)
}

if (file.access(input_path, mode = 4) != 0) {
    stop("Input file is not readable: ", input_path, call. = FALSE)
}

# 3. Read the CSV and inspect its header and first few rows
trees <- read.csv(
    input_path, 
    check.names = FALSE, 
    stringsAsFactors = FALSE
)

# Inspec the column names and first few rows
cat("Input columns:\n")
print(names(trees))

cat("\nFirst six rows:\n")
print(head(trees,6))

# 4. Check the exact column names and order
expected_columns <- c(
    "Species",
    "Distance.m",
    "Angle.degrees"
)

if (!identical(names(trees), expected_columns)) {
    stop(
        "Wrong CSV header, Expected exactly: ",
        paste(expected_columns, collapse = ", "),
        call. = FALSE
    )
}

# 5. Check that Distance.m and Angle.degrees are numeric and finte
numeric_columns <- c("Distnace.m", "Angle.degrees")

for (column in numeric_columns) {
    values <- tress[[column]]

    if(!is.numeric(values)) {
        stop(
            "Column '", column, "' must contain numeric values.",
            call. = FALSE
        )
    }

    bad_rows <- which(!is.finite(values))
    
    if(length(bad_rows) > 0) {
        stop(
            "Column '", column,
            "' contains a missing or non-finite value at CSV line ",
            bad_rows[1] +1, ".",
            call. = FALSE
        )
    }
}

# 6. Check distance: 0 < Distance.m <= 100
bad_distance <- which(
    trees$Distance.m <= 0 | trees$Distance.m > 100
)
if(lenght(bad_distance) > 0 {
    i <- bad_distance[1]

    stop(
        "Invalid Distance.m at CSV line ", i + 1,
        ": found ", trees$Distance.m[i],
        "; expected a value greater than 0 and at most 100.",
        call. = FALSE
    )
}

# 7. Check angle: 0 < Angle.degrees <90 
bad_angle <- which(
    trees$Angle.degrees <= 0 | trees$Angle.degrees >=90
)

if(length(bad_angle) > 0) {
    i <- bad_angle[1]
    
    stop(
        "Invalid Angle.degrees at CSV line ", i + 1,
        ": found ", trees$Angle.degrees[i],
        "; expected a value greater than 0 and less than 90.",
        call. = FALSE
    )
}

# 8. Define the tree-height calculation
TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return(height)
}

#9. Debugging: pause immediately before calculating heights 
# Inspect one row, calculate its expected height manually,
# then use n to execute the next line and c to continue. 

browser()

trees$height_m <- TreeHeight(
    trees$Angle.degrees,
    trees$Distance.m
)

# 10. Create the results directory if necessary 
dir.create(
    "results",
    showWarnings = FALSE,
    recursive = TRUE
)

# 11. Build the output name from the input basename 
input_basename <- basename(input_path)

input_stem <- sub(
    "\\.csv$",
    "",
    input_basename,
    ignore.case = TRUE
)

output_path <- file.path(
    "results",
    paste0(input_stem, "_treeheights.csv")
)

# Refuse to overwrite the input file
normal_input <- normalizePath(input_path, mustWork = TRUE)
normal_output <- normalizePath(output_path, mustWork = FALSE)

if(identical(normal_input, normal_output)) {
    stop(
        "Refusing to overwrite the input file: ", input_path,
        call. = FALSE
    )
}


# 12. Write the output, replacing it if it already exists
write.csv(
    trees, 
    file = output_path,
    row.names = FALSE
)

cat("\nTree heights calculated successfully.\n")
cat("Output saved to: ", output_path, "\n", sep = "")