import math
import hashlib
from datetime import datetime, UTC
from dateutil import parser


def normalize_timestamp(ts):
    return parser.parse(ts).isoformat()


def generate_id(timestamp, machine_id):
    key = f"{timestamp}_{machine_id}"
    return hashlib.md5(key.encode()).hexdigest()


def transform(row):
    sensors = {}

    for k, v in row.items():
        if k.startswith("sensor_"):
            try:
                val = float(v)
                sensors[k] = None if math.isnan(val) else val
            except:
                sensors[k] = None

    normalized_ts = normalize_timestamp(row["timestamp"])
    machine_id = row.get("machine_id", 1)

    insert_id = generate_id(normalized_ts, machine_id)

    return {
        "insert_id": insert_id,
        "timestamp": normalized_ts,
        "machine_id": machine_id,
        "machine_status": row.get("machine_status"),
        "ingestion_time": datetime.now(UTC).isoformat(),
        **sensors
    }