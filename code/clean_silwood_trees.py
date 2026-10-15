
#!/usr/bin/env python3
"""
Validate and clean the synthetic Silwood tree survey.

PSEUDOCODE OVERVIEW
1. Set up project-relative input and output paths.
2. Define valid locations, taxa, columns, and record ID format.
3. Load the raw CSV and check its required columns.
4. Validate each record and separate accepted records from rejected ones.
5. Sort accepted records and count accepted oak records by species.
6. Write the cleaned data, validation issues, and oak counts to CSV files.
7. Print a summary when the script finishes.
"""

from pathlib import Path
import csv
import math
import re


# ==================================================
# 1. SET UP FILE PATHS
# ==================================================
# PSEUDOCODE:
# - Find the project root from the location of this script.
# - Locate the raw CSV inside the data directory.
# - Define the results directory and output filenames.

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_FILE = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"
RESULTS_DIR = PROJECT_ROOT / "results"

CLEAN_FILE = RESULTS_DIR / "silwood_trees_clean.csv"
ISSUES_FILE = RESULTS_DIR / "silwood_tree_issues.csv"
OAK_COUNTS_FILE = RESULTS_DIR / "oak_species_counts.csv"


# ==================================================
# 2. DEFINE REQUIRED FIELDS AND VALID VALUES
# ==================================================
# PSEUDOCODE:
# - Define the required CSV column names.
# - Define permitted survey locations and their canonical names.
# - Define permitted genus/species combinations.
# - Define the required format for record IDs.

FIELDS = [
    "record_id",
    "location",
    "genus",
    "species",
    "distance_m",
    "angle_degrees",
]

ISSUE_FIELDS = ["source_row", "record_id", "reasons"]
OAK_COUNT_FIELDS = ["species", "count"]

LOCATIONS = {
    "silwood bottom": "Silwood Bottom",
    "nash's field": "Nash's Field",
    "manor house": "Manor House",
    "reactor wood": "Reactor Wood",
}

TAXA = {
    ("Quercus", "robur"),
    ("Quercus", "petraea"),
    ("Acer", "pseudoplatanus"),
    ("Betula", "pendula"),
    ("Fagus", "sylvatica"),
    ("Fraxinus", "excelsior"),
}

GENERA = {
    genus.casefold(): genus
    for genus, _ in TAXA
}

SPECIES = {
    species.casefold(): species
    for _, species in TAXA
}

RECORD_ID_PATTERN = re.compile(r"ST\d{3}")


# ==================================================
# 3. DEFINE A NUMERIC CONVERSION HELPER
# ==================================================
# PSEUDOCODE:
# - Remove surrounding whitespace.
# - If the value is missing, return None.
# - Try to convert the value to a number.
# - If conversion fails or the number is not finite,
#   return None.
# - Otherwise, return the converted number.

def parse_number(value):
    value = (value or "").strip()

    if not value:
        return None

    try:
        number = float(value)
    except (ValueError, TypeError):
        return None

    if not math.isfinite(number):
        return None

    return number


# ==================================================
# 4. LOAD THE RAW CSV
# ==================================================
# PSEUDOCODE:
# - Open the raw CSV without modifying it.
# - Check that the required columns are present.
# - Read all records and return them.

def load_records():
    with DATA_FILE.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:

        reader = csv.DictReader(file)

        if reader.fieldnames is None:
            raise ValueError("Input CSV is empty or has no header.")

        missing = set(FIELDS) - set(reader.fieldnames)

        if missing:
            raise ValueError(
                "Missing required columns: "
                + ", ".join(sorted(missing))
            )

        return list(reader)


# ==================================================
# 5. VALIDATE ONE RECORD
# ==================================================
# PSEUDOCODE:
# - Create an empty list of validation errors.
# - Clean text fields and check the record ID.
# - Check the location against permitted locations.
# - Check genus and species independently.
# - If both are recognised, check their combination.
# - Convert distance and angle to finite numbers.
# - Check their permitted ranges.
# - If any errors exist, return an issue record.
# - Otherwise, return the cleaned record.
#
# Record ID duplicates are checked against accepted IDs only.

def validate_record(row, source_row, accepted_ids):
    reasons = []
    cleaned = {}

    # Validate record ID
    record_id = (row.get("record_id") or "").strip()
    cleaned["record_id"] = record_id

    if not record_id:
        reasons.append("missing record_id")
    elif not RECORD_ID_PATTERN.fullmatch(record_id):
        reasons.append("invalid record_id")
    elif record_id in accepted_ids:
        reasons.append("duplicate record_id")

    # Validate location
    location = (row.get("location") or "").strip()

    if not location:
        reasons.append("missing location")
    elif location.casefold() not in LOCATIONS:
        reasons.append("invalid location")
    else:
        cleaned["location"] = LOCATIONS[location.casefold()]

    # Validate genus
    genus = (row.get("genus") or "").strip()

    if not genus:
        reasons.append("missing genus")
    elif genus.casefold() not in GENERA:
        reasons.append("invalid genus")
    else:
        cleaned["genus"] = GENERA[genus.casefold()]

    # Validate species
    species = (row.get("species") or "").strip()

    if not species:
        reasons.append("missing species")
    elif species.casefold() not in SPECIES:
        reasons.append("invalid species")
    else:
        cleaned["species"] = SPECIES[species.casefold()]

    # Validate genus/species combination
    if (
        genus.casefold() in GENERA
        and species.casefold() in SPECIES
    ):
        pair = (
            GENERA[genus.casefold()],
            SPECIES[species.casefold()],
        )

        if pair not in TAXA:
            reasons.append("invalid genus/species combination")

    # Validate distance: 0 < distance <= 100
    distance_text = (row.get("distance_m") or "").strip()

    if not distance_text:
        reasons.append("missing distance_m")
    else:
        distance = parse_number(distance_text)

        if distance is None:
            reasons.append("invalid distance_m")
        elif distance <= 0 or distance > 100:
            reasons.append("distance_m out of range")
        else:
            cleaned["distance_m"] = distance

    # Validate angle: 0 < angle < 90
    angle_text = (row.get("angle_degrees") or "").strip()

    if not angle_text:
        reasons.append("missing angle_degrees")
    else:
        angle = parse_number(angle_text)

        if angle is None:
            reasons.append("invalid angle_degrees")
        elif angle <= 0 or angle >= 90:
            reasons.append("angle_degrees out of range")
        else:
            cleaned["angle_degrees"] = angle

    # Reject the record if any validation errors occurred
    if reasons:
        return None, {
            "source_row": source_row,
            "record_id": record_id,
            "reasons": ";".join(reasons),
        }

    return cleaned, None


# ==================================================
# 6. PROCESS ALL RECORDS
# ==================================================
# PSEUDOCODE:
# - Initialise lists for accepted records and issues.
# - Initialise a set of accepted record IDs.
# - Process every input row, starting source numbering at 2.
# - Validate each row.
# - Store rejected rows with their error messages.
# - Store accepted rows and register their IDs.
# - Sort accepted records by record ID.
# - Return accepted records and issues.

def process_records(records):
    accepted_records = []
    issues = []
    accepted_ids = set()

    for source_row, row in enumerate(records, start=2):
        cleaned, issue = validate_record(
            row,
            source_row,
            accepted_ids,
        )

        if issue is not None:
            issues.append(issue)
        else:
            accepted_records.append(cleaned)
            accepted_ids.add(cleaned["record_id"])

    accepted_records.sort(
        key=lambda record: record["record_id"]
    )

    return accepted_records, issues


# ==================================================
# 7. COUNT ACCEPTED OAK RECORDS
# ==================================================
# PSEUDOCODE:
# - Examine accepted records only.
# - Select records whose genus is Quercus.
# - Count records for each oak species.
# - Sort species alphabetically.
# - Return the counts as a list of records.

def summarise_oaks(records):
    counts = {}

    for record in records:
        if record["genus"] == "Quercus":
            species = record["species"]
            counts[species] = counts.get(species, 0) + 1

    return [
        {"species": species, "count": counts[species]}
        for species in sorted(counts)
    ]


# ==================================================
# 8. WRITE OUTPUT CSV FILES
# ==================================================
# PSEUDOCODE:
# - Open an output file for writing.
# - Write the column headers.
# - Write all supplied records.

def write_csv(path, fieldnames, records):
    with path.open(
        "w",
        newline="",
        encoding="utf-8",
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames,
        )

        writer.writeheader()
        writer.writerows(records)


# ==================================================
# 9. RUN THE COMPLETE WORKFLOW
# ==================================================
# PSEUDOCODE:
# - Check that the input CSV exists.
# - Create the results directory if necessary.
# - Load and validate all input records.
# - Summarise accepted oak records.
# - Write the three output CSV files.
# - Print a summary of the results.

def main():
    if not DATA_FILE.is_file():
        raise FileNotFoundError(
            f"Input CSV not found: {DATA_FILE}"
        )

    RESULTS_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    raw_records = load_records()
    clean_records, issues = process_records(raw_records)
    oak_counts = summarise_oaks(clean_records)

    write_csv(CLEAN_FILE, FIELDS, clean_records)
    write_csv(ISSUES_FILE, ISSUE_FIELDS, issues)
    write_csv(OAK_COUNTS_FILE, OAK_COUNT_FIELDS, oak_counts)

    print("Processing complete.")
    print(f"Input records: {len(raw_records)}")
    print(f"Accepted records: {len(clean_records)}")
    print(f"Rejected records: {len(issues)}")
    print(f"Cleaned data: {CLEAN_FILE}")
    print(f"Validation issues: {ISSUES_FILE}")
    print(f"Oak species counts: {OAK_COUNTS_FILE}")


# ==================================================
# 10. CONTROL EXECUTION
# ==================================================
# PSEUDOCODE:
# - Run main() only if this file is executed directly.
# - Do not automatically process records when imported.

if __name__ == "__main__":
    main()