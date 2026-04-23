# ML Inference API (External Service)

This document describes the external machine learning inference API used by the pipeline.

## Overview

The pipeline integrates with an external ML service to enrich sensor data with predictions such as:

* Equipment health classification
* Anomaly detection signals
* Failure risk estimation

> Note: The ML service is external and not part of this repository.
> This reflects real-world systems where ML and data pipelines are decoupled.

---

## Endpoint

POST `/predict`

---

## Request

```json
{
  "sensor_00": 0.123,
  "sensor_01": 0.456,
  "sensor_02": 0.789,
  "machine_id": 1
}
```

---

## Response

```json
{
  "prediction": "NORMAL",
  "confidence": 0.87
}
```

---

## Integration Pattern

1. Extract features from BigQuery
2. Call external ML API
3. Store predictions back into BigQuery

---

## Design Rationale

* Decouples ML lifecycle from data pipeline
* Allows independent scaling of ML services
* Reflects production-grade architecture
