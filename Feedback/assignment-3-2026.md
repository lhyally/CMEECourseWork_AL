# Assignment 3 formative feedback

This feedback is organised using the [Computing Bootcamp rubric](https://mulquabio.github.io/MQB/rubrics/Computing_Bootcamp_Rubric.html). It does not award a mark; use it to decide what to revise and check before final submission.

## Criterion 1: Repository organisation & workflow discipline

- Before final submission, **Make output regeneration and documentation reproducible.** Generated files, including the tree-height and Pound Hill outputs, are tracked, but `.gitignore` does not exclude `results/`. Stop tracking generated results while retaining them locally, add an appropriate ignore rule, and ensure each program creates its output directory. Your README explains purposes but lacks concrete Assignment 3 run and test examples; add commands, dependencies and expected output paths so another reader can reproduce the full route.

## Criterion 2: Code completeness & functional correctness

- Before final submission, **Make the tree-height routes runnable independently.** The interface check stopped because `TreeHeight.R` reads from your personal `~/Documents/CMEECourseWork/` path when sourced. Use a project-relative input path and ensure loading the function does not depend on that personal directory. Keep the first argument as angle in degrees and the second as horizontal distance; try the taught example call and compare it with a direct calculation. The fixed and generalised programs need separate tests.
- Before final submission, **Repair the generalised route before judging its validation.** Its normal run stopped at `object 'tress' not found`, and `results/trees_treeheights.csv` was not produced. Your code also shows `Distnace.m`, `lenght` and an incomplete condition in the distance check. Check these names and syntax systematically, then remove the interactive `browser()` pause from the submission workflow. Correct the wrapper’s interpreter line before testing direct execution.

## Criterion 3: Code quality & style

As you revise, keep names descriptive, use comments to explain decisions rather than restating code, and avoid repeating the same calculation in several places.

## Criterion 4: Documentation

- All required source and input paths are present, alongside a root README and `.gitignore`. The supplied input files match the original data.

## Criterion 5: Version-control practice

Commit each functional revision with a short message that says what changed; this makes your development easier to follow than one large final commit.

## Criterion 8: Basic error-handling & input validation

- Before final submission, **Check that invalid inputs fail for the intended reason.** Although both invalid-input tests the expected exit, their errors were the same unrelated path/object errors seen above. They therefore do not demonstrate rejection of the bad measurement. The fixed script also contains `trees$Distance,m[i]` in its distance-error message. After repairing the normal runs, use a copy of the input with one invalid value: confirm that the message identifies the relevant field or row and that no new result is written.

## Criterion 9: Problem-solving approach & method implementation

- Your code shows that `TreeHeight` takes the angle in degrees first and horizontal distance second, converts degrees to radians and applies the stated trigonometric method. Your comments explain the arguments and units; execution has not yet verified the callable interface.
- The Pound Hill source separates data preparation, validation, quadrat summaries and plot-level means. It explicitly distinguishes richness from abundance and explains its dataset-specific treatment of blank counts. These are useful foundations for tracing measurements through to outputs, though the generated values remain unchecked.

## Criterion 10: Learning progression demonstration

Use this feedback as a revision checklist. Make the changes in small, descriptive commits, then add a short README note explaining what you changed and how you checked it. This will make your development from this formative checkpoint visible in the final portfolio.

## Priorities before final submission

- Run commands from the directory containing `code/`, `data/` and the root `README.md`. Test each tree-height route with one ordinary and one invalid case, reading stderr as well as checking output files.
- Your debugging comments propose an independent height calculation, but do not record a completed comparison. Document one measurement, your direct calculation and its agreement with the generated height.
- Regenerate `results/pound_hill_plot_richness.csv` and `results/pound_hill_plot_richness.pdf`. These files are tracked, not confirmed missing; newly generated copies were unavailable in the collected archive, so their contents and figure quality were not checked. Compare one plot mean with its underlying quadrat richness values, then inspect the PDF’s labels, values and biological meaning. Replace the visible interpretation prompts with your own evidence-based observations if these have not already been completed elsewhere.
- Commit the repairs with descriptive messages.
