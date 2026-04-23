import json
import time
import random
import pandas as pd
from kafka import KafkaProducer

from streaming.config.settings import KAFKA_BOOTSTRAP, TOPICS

df = pd.read_csv("./data/sensor.csv")

producer = KafkaProducer(
    bootstrap_servers=[KAFKA_BOOTSTRAP],
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

for _, row in df.iterrows():
    message = {
        **row.to_dict(),
        "machine_id": 1,
        "event_source": "simulator"
    }

    producer.send(TOPICS["raw"], value=message)

    print("📤 Sent:", message["timestamp"])
    time.sleep(random.uniform(0.05, 0.3))

producer.flush()