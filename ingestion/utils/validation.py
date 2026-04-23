def validate(row):
    if "timestamp" not in row:
        raise ValueError("Missing timestamp")

    if "machine_id" not in row:
        raise ValueError("Missing machine_id")

    return True