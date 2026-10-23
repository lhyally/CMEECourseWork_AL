# This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
#
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# The heights of the tree, same units as "distance"

TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return(height)
}

# Load the data from the project root: 
trees <- read.csv("~/Documents/CMEECourseWork/data/trees.csv")

# Check for the three required columns: 
required_columns <- c("Species", "Distance.m", "Angle.degrees")
missing_columns <- setdiff(required_columns, names(trees))
if (length(missing_columns) > 0) {
    stop(
        "Input validation failed, missing required column(s),",
        paste(missing_columns, collapse = ", ")
    )
}
# Check the angles and distance are numeric and finite:
numeric_columns <- c("Distance.m", "Angle.degrees")

for(column in numeric_columns) {
    values <- trees[[column]]
    if (!is.numeric(values)) {
        stop(
            "Input validation failed: column '", column,
            "' must contain numeric values; found ",
            paste(class(values), collapse = "/"), "."
        )
    }
    bad_rows <- which(!is.finite(values))
    if (length(bad_rows) > 0) {
        stop(
            "Input validation failed, column '", column,
            "'contains a missing or non-finite value",
            bad_rows[1] + 1, "."
        )
    }
}

# Check the allowed ranges for Distance.m and Angles.degrees: 
bad_distance <- which(
    trees$Distance.m <= 0 | trees$Distance.m > 100
)

if (length(bad_distance) > 0) {
    i <- bad_distance [1]

    stop(
        "Input validation failed", i + 1,
        ", Distance.m = ", trees$Distance,m[i],
        "; expected 0 < Distance.m <= 100."
    )
}

bad_angle <- which(
    trees$Angle.degrees <= 0 | trees$Angle.degrees >= 90
)

if(length(bad_angle) > 0) {
    i <- bad_angle[1]
    stop(
        "Input validation failed", i + 1, 
        ", Angle.degrees = ", trees$Angle.degrees[i],
        "; expected 0 < Angle,degrees < 90."
    )
}

cat("\nInput validation passed, ready to calculate tree heights.\n")


# Calculating heights for each trees 
trees$Tree.Height.m <- TreeHeight(
    trees$Angle.degrees,
    trees$Distance.m
)

# Save the original data and calculated heights to a CSV file
write.csv(
    trees,
    file = "results/TreeHts.csv",
    row.names = FALSE
)