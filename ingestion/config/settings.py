PROJECT_ID = "sensor-data-pipeline-492507"
BQ_TABLE = f"{PROJECT_ID}.sensor_data.sensor_raw"

KAFKA_BOOTSTRAP = "localhost:9092"

TOPICS = {
    "raw": "sensor.raw",
    "cleaned": "sensor.cleaned",
    "dlq": "sensor.dlq"
}

BATCH_SIZE = 100
MAX_RETRIES = 3