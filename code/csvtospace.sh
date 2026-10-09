#!/usr/bin/env bash

# Check that exactly one argument is supplied
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one CSV input file." >&2
    exit 1
fi

# Store the input filename
input="$1"

# Check that the input exists and is readable
if [ ! -f "$input" ] || [ ! -r "$input" ]; then
    echo "Error: Input file does not exist or is not readable." >&2
    exit 1
fi

# Create results directory if necessary
mkdir -p ../results || {
    echo "Error: Could not create results directory." >&2
    exit 1
}

# Set the output filename
filename=$(basename "$input")
output="../results/$filename.txt"

echo "Creating a space delimited version of $input ..."

# Replace commas with spaces, preserving repeated delimiters
if tr ',' ' ' < "$input" > "$output"; then
    echo "Done!"
else
    echo "Error: Conversion failed." >&2
    exit 1
fi

exit 0