#!/usr/bin/env python3

#!/usr/bin/env python3
"""Validate and clean the synthetic Silwood tree survey."""

from pathlib import Path
import csv
import math
import re


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_FILE = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"
RESULTS_DIR = PROJECT_ROOT / "results"

CLEAN_FILE = RESULTS_DIR / "silwood_trees_clean.csv"
ISSUES_FILE = RESULTS_DIR / "silwood_tree_issues.csv"
OAK_COUNTS_FILE = RESULTS_DIR / "oak_species_counts.csv"

FIELDS = [
    "record_id", "location", "genus",
    "species", "distance_m", "angle_degrees",
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
GENERA = {genus.casefold(): genus for genus, _ in TAXA}
SPECIES = {species.casefold(): species for _, species in TAXA}
RECORD_ID_PATTERN = re.compile(r"ST\d{3}")


def parse_number(value):
    """Return a finite float, or None if conversion fails."""
    value = (value or "").strip()
    if not value:
        return None
    try:
        number = float(value)
    except (ValueError, TypeError):
        return None
    return number if math.isfinite(number) else None


def validate_record(row, source_row, accepted_ids):
    """Validate one record and return (cleaned_record, issue)."""
    reasons = []
    cleaned = {}

    record_id = (row.get("record_id") or "").strip()
    cleaned["record_id"] = record_id

    if not record_id:
        reasons.append("missing record_id")
    elif not RECORD_ID_PATTERN.fullmatch(record_id):
        reasons.append("invalid record_id")
    elif record_id in accepted_ids:
        reasons.append("duplicate record_id")

    location = (row.get("location") or "").strip()
    if not location:
        reasons.append("missing location")
    elif location.casefold() not in LOCATIONS:
        reasons.append("invalid location")
    else:
        cleaned["location"] = LOCATIONS[location.casefold()]

    genus = (row.get("genus") or "").strip()
    if not genus:
        reasons.append("missing genus")
    elif genus.casefold() not in GENERA:
        reasons.append("invalid genus")
    else:
        cleaned["genus"] = GENERA[genus.casefold()]

    species = (row.get("species") or "").strip()
    if not species:
        reasons.append("missing species")
    elif species.casefold() not in SPECIES:
        reasons.append("invalid species")
    else:
        cleaned["species"] = SPECIES[species.casefold()]

    if genus.casefold() in GENERA and species.casefold() in SPECIES:
        pair = (GENERA[genus.casefold()], SPECIES[species.casefold()])
        if pair not in TAXA:
            reasons.append("invalid genus/species combination")

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

    if reasons:
        return None, {
            "source_row": source_row,
            "record_id": record_id,
            "reasons": ";".join(reasons),
        }

    return cleaned, None


def load_records():
    """Read the raw CSV without modifying it."""
    with DATA_FILE.open(
        "r", newline="", encoding="utf-8-sig"
    ) as file:
        reader = csv.DictReader(file)
        if reader.fieldnames is None:
            raise ValueError("Input CSV is empty or has no header.")

        missing = set(FIELDS) - set(reader.fieldnames)
        if missing:
            raise ValueError(
                "Missing required columns: " + ", ".join(sorted(missing))
            )
        return list(reader)


def process_records(records):
    """Validate all records and collect accepted rows and issues."""
    accepted_records = []
    issues = []
    accepted_ids = set()

    for source_row, row in enumerate(records, start=2):
        cleaned, issue = validate_record(row, source_row, accepted_ids)
        if issue is not None:
            issues.append(issue)
        else:
            accepted_records.append(cleaned)
            accepted_ids.add(cleaned["record_id"])

    accepted_records.sort(key=lambda record: record["record_id"])
    return accepted_records, issues


def summarise_oaks(records):
    """Count accepted Quercus records by species."""
    counts = {}
    for record in records:
        if record["genus"] == "Quercus":
            species = record["species"]
            counts[species] = counts.get(species, 0) + 1

    return [
        {"species": species, "count": counts[species]}
        for species in sorted(counts)
    ]


def write_csv(path, fieldnames, records):
    """Write a list of dictionaries to a CSV."""
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)


def main():
    if not DATA_FILE.is_file():
        raise FileNotFoundError(f"Input CSV not found: {DATA_FILE}")

    RESULTS_DIR.mkdir(parents=True, exist_ok=True)

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


if __name__ == "__main__":
    main()