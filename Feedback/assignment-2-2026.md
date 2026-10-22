# Assignment 2 formative feedback

This feedback is organised by the relevant computing bootcamp criteria. Use it to decide what is already working, what you need to investigate, and what to revise before the cumulative submission.

The full criteria are in the [Computing Bootcamp assessment rubric](https://github.com/MulQuaBio/MQB/blob/main/content/rubrics/Computing_Bootcamp_Rubric.md).

## 1. Repository organisation and workflow discipline

- Your root README, `.gitignore`, cleaning script and supplied data files are in the expected locations, and the supplied inputs are unchanged. Add `code/test_silwood_trees.py` under `code/`, as described under Criterion 8.

## 2. Code completeness and functional correctness

- **Check output generation independently of existing results.** `results/silwood_trees_clean.csv` was already committed, so I could not verify that the script created it rather than reusing an existing file. I could not inspect the three generated tables, so the output-writing step still needs checking. Make a separate copy of your repository in a new folder using `git clone` and confirm that the generated CSV files are not already present. Run the script there, then inspect all three newly generated tables. Use one accepted and one rejected record as assertions in your separate test file, and check that the oak summary uses only the accepted collection.
- After removing generated outputs from Git tracking, make a separate copy of your repository in a new folder using `git clone`. Run the cleaner there, then inspect the headers and representative rows in all three output tables and check that they agree with the accepted and rejected collections.

## 3. Code quality and style

- Your `main()` function gives the program a clear overall structure by connecting loading, processing, summarising and writing. Keep these stages distinct as you revise; use descriptive names and add short comments where the reason for a validation check or data-cleaning step is not obvious.

## 4. Documentation

- Your root README is in place. Make it useful to someone opening the repository for the first time: explain what the cleaner does, how to run the script and tests from the repository root, and which three files it creates. Test the instructions in a newly cloned copy of your repository (a separate folder created with `git clone`): enter that folder and run each README command exactly as written. If something fails, correct the command or add the missing step.

## 5. Version-control practice

- Since the previous formative feedback was added, the saved history contains 3 non-merge commits. `Add Silwood tree survey cleaning workflow` describes a meaningful change, but `Assignment 2` is too broad and `Delete result directory` does not explain why the deletion was needed.
- Before each commit, run `git diff --staged` to see exactly what will be recorded. Keep one coherent, working change per commit and write a concise message that names what changed—for example, the validation rule added, the failing test fixed or the README instruction clarified.
- `results/silwood_trees_clean.csv` is currently tracked by Git. After confirming that it is a generated file, run `git rm --cached results/silwood_trees_clean.csv`; this removes it from Git without deleting your local copy. Keep the results path in `.gitignore`, commit the change, and use `git status` to confirm that generated CSVs will not be included again.

## 8. Basic error handling and input validation

- **Add separate, meaningful tests.** `code/test_silwood_trees.py` is absent. This requirement was added retrospectively, so its absence is not treated as disregard of the original instructions, but the file is required for the final cumulative submission. Separate tests make helper behaviour repeatable and help locate errors before a full run. Start with a valid record, an invalid record and a boundary case from the released requirements; check both validation decisions and the split into accepted records and issues.
- Add and run the separate test file, using explicit assertions rather than only printing results.
- Check that the root README explains the workflow and gives working run and test commands.

## 9. Problem-solving approach and method implementation

- Your code shows a clear, connected workflow: `main()` calls `load_records()` to read the supplied CSV, then `process_records()` calls `validate_record()` and returns `(accepted_records, issues)`. The cleaned collection feeds `summarise_oaks()`, followed by three calls to `write_csv()`. This structure makes the intended flow of data easy to follow.
- Before final submission, add or refine a small assertion-based test in `code/test_silwood_trees.py` using one valid and one invalid record. Check that `process_records()` places them in the cleaned and issues collections respectively, then pass the cleaned collection to `summarise_oaks()` and check that the invalid record does not contribute. Run the complete cleaner and inspect the three output files. Briefly explain this flow in your root README.
