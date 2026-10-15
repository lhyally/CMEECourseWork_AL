# Assignment 1 feedback - Ally Lau

**Formative feedback | Rubric 2026.2**

The Unix explanations recognise ambiguity symbols and the need to join wrapped sequence lines. The converters also have useful checking, quoting and conversion-error handling. The README's references to external utilities are helpful, but the submission still needs to connect those ideas to reproducible commands and the right inputs.

Two committed FASTA files, 407228326.fasta and e_coli.fasta, differ from the supplied references. No dependent Unix command was launched, so there are no verified numerical results for those answers. Compare the files with the released originals first; do not use a locally quoted result as a substitute for that check.

There are source-level corrections to make as well. The FASTA paths do not work from code/, and Q1 separates the intended data directory from its wildcard. In Q5, gsub counts an uninitialised seq variable rather than the sequence being read. Also, passing a decimal already calculated by awk into bc does not recover precision that has already been lost. Explain where each count actually comes from.

Align the converters' ../results paths with repository-root execution, add the missing own TSV and untrack the four generated temperature outputs. Some fresh-output checks could not run while those outputs were committed. Expand the README from utility references into actual purposes, run examples, tests, dependencies and any help record. Keep the validation structure and use focused commits for these corrections.

---

## Project structure

Relevant tracked layout (simplified; missing required paths are marked):

```text
README.md
.gitignore
code/  unixPrac1.txt, tabtocsv.sh, csvtospace.sh
data/fasta/  3 required files present
data/temperatures/  4 required files present
data/tab-example.tsv [missing]
results/  4 files tracked
sandbox/  21 files tracked
Also: result/
Input-content differences: data/fasta/407228326.fasta, data/fasta/e_coli.fasta
```

The root code and supplied input filenames are present, but the own TSV is missing. Both result/ and results/ exist in the tracked tree: the singular directory has a placeholder, while the plural one contains generated conversions. Sandbox tests and compiled caches are also tracked. Two FASTA contents differ from the released inputs.

Use one clearly documented results/ destination, untrack generated outputs/caches and keep disposable sandbox work local. Preserve useful classroom source in code/. Add the own TSV and resolve the input discrepancies. Extra folders should clarify the workflow, not leave readers guessing which output location is authoritative.

**Assessed snapshot:** `97db8df0f0cdeabbd66c807064daea7a0fec2468`
