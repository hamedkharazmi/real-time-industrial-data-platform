import json
from kafka import KafkaConsumer, KafkaProducer

from streaming.config.settings import KAFKA_BOOTSTRAP, TOPICS
from streaming.utils.transform import transform
from streaming.utils.validation import validate

consumer = KafkaConsumer(
    TOPICS["raw"],
    bootstrap_servers=[KAFKA_BOOTSTRAP],
    auto_offset_reset="latest",
    enable_auto_commit=True,
    group_id="processor-group",
    value_deserializer=lambda x: json.loads(x.decode("utf-8"))
)

producer = KafkaProducer(
    bootstrap_servers=[KAFKA_BOOTSTRAP],
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

print("🚀 Processor running...")

for msg in consumer:
    try:
        data = msg.value

        validate(data)
        clean = transform(data)

        producer.send(TOPICS["cleaned"], value=clean)

    except Exception as e:
        producer.send(TOPICS["dlq"], value={
            "error": str(e),
            "payload": msg.value
        })