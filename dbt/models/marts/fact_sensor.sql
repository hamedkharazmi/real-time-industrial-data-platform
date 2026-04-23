{{ config(
    materialized='incremental',
    partition_by={
      "field": "ingestion_time",
      "data_type": "timestamp"
    },
    cluster_by=["machine_status", "machine_id"]
) }}

WITH base AS (
    SELECT *
    FROM {{ ref('int_sensor_clean') }}
)

SELECT *
FROM base

{% if is_incremental() %}

WHERE ingestion_time > (
    SELECT MAX(ingestion_time) FROM {{ this }}
)
OR timestamp > (
    SELECT TIMESTAMP_SUB(MAX(timestamp), INTERVAL 1 HOUR)
    FROM {{ this }}
)

{% endif %}