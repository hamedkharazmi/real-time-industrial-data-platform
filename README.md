# Real-Time Industrial Data Platform

A production-style data engineering project that builds an end-to-end pipeline for ingesting, processing, transforming, and serving industrial sensor data on Google Cloud.

This project focuses on **data platform design**, enabling real-time analytics and **integration with downstream systems such as machine learning services and monitoring dashboards**.

---

## 🚀 Overview

This pipeline processes high-frequency sensor data from industrial equipment and transforms it into analytics-ready datasets.

It is designed to reflect **real-world data engineering systems**, with clear separation between ingestion, storage, transformation, and serving layers.

---

## 🧠 What This Project Demonstrates

* Designing end-to-end data pipelines on GCP
* Building streaming ingestion systems with Kafka
* Implementing analytics engineering workflows using dbt
* Orchestrating pipelines with Kestra
* Structuring scalable and modular data platforms
* Preparing data for downstream ML systems (without coupling to them)

---

## 🏗️ Architecture

```
Data Source → Kafka → Processing → BigQuery → dbt → Analytics Layer → Dashboard / External ML
```

### Layers

* **Ingestion Layer**: Streaming data using Kafka
* **Storage Layer**: Data lake (GCS) and warehouse (BigQuery)
* **Transformation Layer**: dbt models (staging → intermediate → marts)
* **Orchestration Layer**: Kestra workflows
* **Serving Layer**: Analytics tables and external integrations

---

## 📦 Tech Stack

* Python 3.12+
* Apache Kafka (streaming ingestion)
* Google Cloud Platform (BigQuery, GCS)
* dbt (data transformation)
* Kestra (orchestration)
* Terraform (infrastructure as code)
* Docker (containerization)

---

## 📊 Dashboard

### Live Dashboard
👉 https://datastudio.google.com/reporting/45d91976-d23b-4ef3-a7db-ff3a5644037f

### Preview

![Dashboard Overview](./dashboard/Data%20Studio%20Dashboard.png)

A Looker Studio dashboard is built on top of the transformed data to provide:

* Machine health overview
* Time-series monitoring
* Derived risk signals based on engineered features

> Note: In this public version, risk scores are derived from proxy logic.
> The focus is on the data pipeline that enables real-time analytics and ML integration.

---

## 🤖 ML Integration (Design)

This pipeline is designed to integrate with external ML services.

* Features are generated in BigQuery using dbt
* Data is prepared for real-time inference
* Predictions are expected to be written back into the warehouse

> In this repository, the ML component is represented as an external API.
> This reflects real-world architectures where ML systems are decoupled from data pipelines.

---

## 📁 Project Structure

```
.
├── infrastructure/        # Terraform (GCP resources)
├── ingestion/            # Kafka producers & processors
├── transformation/       # dbt models
├── orchestration/        # Kestra workflows
├── notebooks/            # EDA & experimentation
├── scripts/              # Utility scripts
├── docs/                 # Detailed documentation
```

---

## ⚙️ Data Flow

### Batch Flow

1. Download historical data (Kaggle)
2. Upload to GCS
3. Load into BigQuery
4. Run dbt transformations

### Streaming Flow

1. Sensor data → Kafka
2. Validation & processing
3. Load into BigQuery
4. Incremental dbt models update analytics tables

---

## 📊 Data Model

Follows a layered (medallion-style) architecture:

* **Raw Layer**: `sensor_raw`
* **Staging Layer**: `stg_sensor`
* **Intermediate Layer**: cleaned + gap-filled data
* **Marts Layer**: `fact_sensor`, `sensor_features`

See `docs/data_model.md` for details.

---

## 🧪 Data Quality & Monitoring

* dbt tests for nulls, ranges, and consistency
* Dead Letter Queue (DLQ) for invalid records
* Structured logging across ingestion and processing

---

## ⚙️ Setup (Quick)

```bash
git clone <repo>
cd project
pip install -e .
```

See full setup guide → `docs/setup.md`

---

## 📌 Notes

This project is based on patterns used in real-world production systems and is adapted into a reproducible public version.

---

## 📄 Documentation

* Architecture → `docs/architecture.md`
* Data Model → `docs/data_model.md`
* API → `docs/api.md`
* Setup Guide → `docs/setup.md`

---

## 🧠 Summary

This is a **data engineering project**, focused on building a scalable and production-like pipeline.

The system is designed to:

* support real-time analytics
* enable downstream ML systems
* reflect modern data platform architecture
