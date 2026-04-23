# Architecture Overview

## System Design

```
Data Source → Ingestion → Storage → Transformation → Serving → Consumers
```

---

## Layers

### Ingestion

Kafka-based streaming ingestion for real-time data.

### Storage

* GCS (data lake)
* BigQuery (warehouse)

### Transformation

dbt models:

* staging
* intermediate
* marts

### Orchestration

Kestra manages:

* scheduling
* retries
* dependencies

### Serving

* Analytics tables
* Dashboard (Looker Studio)
* External ML systems

---

## Key Design Principles

* Modular architecture
* Layered data modeling
* Decoupled ML integration
* Scalable cloud-native design
