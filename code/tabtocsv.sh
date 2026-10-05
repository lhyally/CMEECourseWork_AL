#!/usr/bin/env bash
echo "Creating a comma delimted version of $1 ..."
cat $1 | tr -s "\t" "," >> $1.csv
echo "Done!"
exit 0
