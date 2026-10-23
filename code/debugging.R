# Define nested functions
outer_function <- function(a) {
    middle_function(a)
}

middle_function <- function(b) {
    inner_function(b)
}

inner_function <- function(c) {
    # intentional error: division by zero 
    result <- c / d
    return(result)
}

# Call the outer function
outer_function(1)


buggy_function <- function(n) {
    result <- n + unknown_variable
    return(result)
}

# Install the released version from CRAN
install.packages("testthat")


doit <- function(x) {
    temp_x <- sample(x, replace = TRUE)

    if (length(unique(temp_x)) > 30) {
        print(paste(
            "Mean of this sample was:",
            as.character(mean(temp_x))
        ))
    } else {
        stop("Couldn't calculate mean: too few unique values!")
    }
}

set.seed(1345) # again, to get the same result for illustration

popn <- rnorm(50)

hist(popn)

lapply(1:15, function(i) doit(popn)) 
result <- lapply(1:15, function(i) try(doit(popn), FALSE))
# the silent argument of try() controls whether those errors are printed in the terminal 
# by default, silent = FALSE = messages are shown 
# use silent = TRUE to suppress them 

class(result)
result

result <- vector("list", 15) # preallocate/initialise
for(i in 1:15) {
    result[[i]] <- try(doit(popn), FALSE)
}

# trying tryCatch()
result <- vector("list", 15)

for (i in 1:15) {
    result[[i]] <- tryCatch(
        doit(popn),
        error = function(e) e
    )
}