Assignment additional utility for the FASTA exercises:
The AT/GC ratio calculation uses awk to count the canonical DNA bases A, t, G and C and calculate the ratio of (A+T) / (G+C), excluding any ambiguous nucleotides that might be present.
The bc -l utility is used to perform decimal division, becasue Bash's built-in arithmetic uses integer division and would lose the decimal part of the calculated output. The -l option loads the standard maths library and sets the default decimal scale to 20.
Both utilities are external commands that may not be available on every system. Check for availability using command -v awk and command -v bc. 
Infomation obtained from the GNU Awk User's Guide and the GNU bc manual. 
