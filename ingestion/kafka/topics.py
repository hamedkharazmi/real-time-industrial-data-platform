from kafka.admin import KafkaAdminClient, NewTopic
from streaming.config.settings import KAFKA_BOOTSTRAP, TOPICS

admin = KafkaAdminClient(
    bootstrap_servers=KAFKA_BOOTSTRAP,
    client_id="setup"
)

topics = [
    NewTopic(name=TOPICS["raw"], num_partitions=3, replication_factor=1),
    NewTopic(name=TOPICS["cleaned"], num_partitions=3, replication_factor=1),
    NewTopic(name=TOPICS["dlq"], num_partitions=1, replication_factor=1),
]

try:
    admin.create_topics(topics)
    print("✅ Topics created")
except Exception as e:
    print("⚠️ Topics may already exist:", e)