# Data Model Documentation

This document describes the data model and schema for the sensor data pipeline.

## Overview

The data model follows a medallion architecture with multiple layers:
- **Raw Layer**: Untouched source data
- **Staging Layer**: Cleaned and typed data
- **Intermediate Layer**: Enhanced data quality
- **Marts Layer**: Analytics-ready tables

## Design Principles

* Layered (medallion-style) architecture
* Incremental processing
* Partitioned storage for performance
* Separation of raw and analytics layers

## Raw Layer

### sensor_raw
Primary raw data table containing all sensor readings.

**Source**: Kafka streaming ingestion

**Partitioning**: By `ingestion_time` (timestamp)

**Clustering**: By `machine_status`, `machine_id`

**Schema**:
```sql
CREATE TABLE `sensor_data.sensor_raw` (
  timestamp TIMESTAMP,
  ingestion_time TIMESTAMP,
  machine_id INT64,
  machine_status STRING,

  -- Sensor readings (20 sensors)
  sensor_00 FLOAT64,
  sensor_01 FLOAT64,
  ...
  sensor_19 FLOAT64,

  -- Metadata
  insert_id STRING,
  event_source STRING
)
```

**Data Types**:
- `timestamp`: Original sensor timestamp
- `ingestion_time`: When data was ingested to BigQuery
- `machine_id`: Equipment identifier
- `machine_status`: Operating status (NORMAL/BROKEN)
- `sensor_XX`: Sensor readings (float values)
- `insert_id`: Unique identifier for deduplication
- `event_source`: Data source identifier

## Staging Layer

### stg_sensor
Cleaned and properly typed sensor data.

**Source**: `sensor_raw` table

**Transformations**:
- Type casting to appropriate data types
- Timestamp conversion
- Column renaming for consistency
- Basic data validation

**Schema**:
```sql
-- Generated dynamically based on sensor columns
SELECT
  timestamp_converted AS timestamp,
  ingestion_time,
  machine_id,
  machine_status,
  SAFE_CAST(sensor_00 AS FLOAT64) AS sensor_00,
  SAFE_CAST(sensor_01 AS FLOAT64) AS sensor_01,
  -- ... all sensor columns
FROM sensor_raw
```

## Intermediate Layer

### int_sensor_clean
Enhanced data quality with gap filling.

**Source**: `stg_sensor` table

**Transformations**:
- Missing value imputation using `fill_sensor_gaps` macro
- Data quality improvements
- Outlier handling

**Gap Filling Logic**:
- Forward fill missing values
- Backward fill remaining gaps
- Linear interpolation for time series

## Marts Layer

### fact_sensor
Core fact table for analytics and reporting.

**Source**: `int_sensor_clean` table

**Materialization**: Incremental

**Partitioning**: By `ingestion_time` (timestamp)

**Clustering**: By `machine_status`, `machine_id`

**Incremental Logic**:
- Load new data since last run
- Handle late-arriving data (1-hour window)

**Schema**:
```sql
CREATE TABLE `sensor_data_marts.fact_sensor` (
  timestamp TIMESTAMP,
  ingestion_time TIMESTAMP,
  machine_id INT64,
  machine_status STRING,
  sensor_00 FLOAT64,
  sensor_01 FLOAT64,
  -- ... all sensor columns
)
PARTITION BY DATE(ingestion_time)
CLUSTER BY machine_status, machine_id
```

### sensor_features
Machine learning features derived from sensor data.

**Source**: `fact_sensor` table

**Materialization**: Full refresh

**Features Generated**:
- Rolling averages (5, 10, 20 periods)
- Rolling standard deviations
- Lag features (1, 2, 3 periods back)
- Rate of change
- Statistical moments

**Window Functions**:
```sql
WINDOW w AS (
  PARTITION BY machine_id
  ORDER BY timestamp
  ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
)
```

**Sample Features**:
- `sensor_00_avg_5`: 5-period rolling average
- `sensor_00_std_10`: 10-period rolling std dev
- `sensor_00_lag_1`: Previous period value
- `sensor_00_roc`: Rate of change

## Analytics Layer

### ml_predictions
Model predictions and inference results.

**Source**: ML serving API via Kestra pipeline

**Schema**:
```sql
CREATE TABLE `sensor_data.ml_predictions` (
  timestamp TIMESTAMP,
  machine_id INT64,
  prediction_score FLOAT64,
  prediction_label STRING,
  confidence FLOAT64,
  model_version STRING,
  inference_time TIMESTAMP
)
```

**Fields**:
- `prediction_score`: Raw model output
- `prediction_label`: Classified result (e.g., "NORMAL", "ANOMALY")
- `confidence`: Model confidence score
- `model_version`: Version of deployed model

## Data Quality

### Tests Implemented

#### Null Value Tests
```sql
-- No null timestamps
SELECT * FROM {{ ref('stg_sensor') }}
WHERE timestamp IS NULL

-- Sensor readings should not be null
SELECT * FROM {{ ref('fact_sensor') }}
WHERE sensor_00 IS NULL OR sensor_01 IS NULL
```

#### Data Drift Tests
```sql
-- Statistical distribution checks
SELECT
  AVG(sensor_00) as avg_value,
  STDDEV(sensor_00) as std_value
FROM {{ ref('fact_sensor') }}
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
```

#### Spike Detection
```sql
-- Detect anomalous spikes
SELECT *
FROM {{ ref('fact_sensor') }}
WHERE ABS(sensor_00 - LAG(sensor_00) OVER (ORDER BY timestamp)) > threshold
```

#### Range Validation
```sql
-- Sensor values within expected ranges
SELECT *
FROM {{ ref('stg_sensor') }}
WHERE sensor_00 < 0 OR sensor_00 > 100
```

## Data Lineage

```
sensor_raw
    ↓
stg_sensor (type casting, basic cleaning)
    ↓
int_sensor_clean (gap filling, quality)
    ↓
fact_sensor (incremental fact table)
    ↓
sensor_features (ML features)
    ↓
ml_predictions (model outputs)
```

## Partitioning Strategy

### Time-Based Partitioning
- **Raw tables**: Partition by `ingestion_time`
- **Fact tables**: Partition by `ingestion_time`
- **Granularity**: Daily partitions

### Clustering Strategy
- **Primary cluster**: `machine_status` (high cardinality filter)
- **Secondary cluster**: `machine_id` (equipment-specific queries)

## Performance Optimizations

### Query Performance
- Partition pruning for time-based queries
- Clustering for equipment-specific analytics
- Incremental loading to reduce processing time

### Storage Optimization
- Columnar storage in BigQuery
- Compression for historical data
- Automatic partitioning management

## Data Retention

### Raw Data
- Retain all raw data for audit purposes
- No automatic deletion

### Processed Data
- Fact tables: Rolling retention (90 days)
- Feature tables: Keep current snapshot
- Predictions: Retain for model evaluation

## Schema Evolution

### Adding New Sensors
1. Update `stg_sensor` to detect new columns
2. Modify `fill_sensor_gaps` macro if needed
3. Update downstream models
4. Add tests for new columns

### Changing Data Types
1. Update staging layer type casting
2. Modify downstream transformations
3. Update tests and validations

### Backfilling Data
1. Use dbt's `--full-refresh` for complete rebuild
2. Implement incremental backfill logic
3. Validate data consistency