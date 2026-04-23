import json
import time
from kafka import KafkaConsumer
from google.cloud import bigquery

from streaming.config.settings import (
    KAFKA_BOOTSTRAP,
    TOPICS,
    BQ_TABLE,
    BATCH_SIZE,
    MAX_RETRIES
)

client = bigquery.Client()

consumer = KafkaConsumer(
    TOPICS["cleaned"],
    bootstrap_servers=[KAFKA_BOOTSTRAP],
    auto_offset_reset="latest",
    enable_auto_commit=False,
    group_id="bq-writer-group",
    value_deserializer=lambda x: json.loads(x.decode("utf-8"))
)


def insert_batch(rows):
    row_ids = [r["insert_id"] for r in rows]
    clean_rows = [{k: v for k, v in r.items() if k != "insert_id"} for r in rows]

    for attempt in range(MAX_RETRIES):
        try:
            errors = client.insert_rows_json(
                BQ_TABLE,
                clean_rows,
                row_ids=row_ids
            )

            if not errors:
                print(f"✅ Inserted {len(rows)} rows")
                return

            print(f"Retry {attempt+1}: {errors}")

        except Exception as e:
            print(f"Retry {attempt+1} Exception:", e)

        time.sleep(2 ** attempt)

    print("❌ Dropped batch")


print("🚀 BQ Writer running...")

batch = []

try:
    for msg in consumer:
        batch.append(msg.value)

        if len(batch) >= BATCH_SIZE:
            start = time.time()
            insert_batch(batch)
            print(f"⚡ Batch took {time.time()-start:.2f}s")

            consumer.commit()
            batch = []

except KeyboardInterrupt:
    print("Stopping...")

finally:
    if batch:
        insert_batch(batch)

    consumer.close()
    print("✅ Shutdown complete")