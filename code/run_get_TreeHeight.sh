#!usr/bin/env bash
set -e

# Run from the project root, regardless of where the command is launched. 
cd "$(dirname "$0")/.."

Rscript code/get_TreeHeight.R data/trees.csv
