#!/usr/bin/env bash

#Check that exactly one argument is supplied
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one input file." >&2
    exit 1
fi

input="$1"

if [ ! -f "$input" ] || [ ! -r "$input" ]; then
    echo "Error: Input file does not exist or is not readable." >&2
    exit 1
fi

#Create the results directory if necessary
mkdir -p ../results || exit 1 

#Set the output filename
filename=$(basename "$input")
output="../results/$filename.csv"

echo "Creating a comma delimted version of $input ..."

#Replace tabs with commas, preserving empty fields 
if tr '\t' ',' < "$input" > "$output"; then 
    echo "Done"
else 
    echo "Error: Conversion failed." >&2
    exit 1
fi 

exit 0 
