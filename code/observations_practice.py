import csv

def load_observations(path):
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))

    if not isinstance(count_text, str):
        raise ValueError("The input must be text.")

    if count_text == "":
        return None

    count = int(count_text)

    if count < 0:
        raise ValueError("Count cannot be negative.")

    return count
    


if __name__ == "__main__":
    rows = load_observations("data/bootcamp_observations.csv")
    print(rows[0])
    print(rows[2])


