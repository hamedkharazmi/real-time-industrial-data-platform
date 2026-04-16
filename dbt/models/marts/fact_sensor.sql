{{ config(
    materialized='incremental',
    partition_by={
      "field": "ingestion_time",
      "data_type": "timestamp"
    },
    cluster_by=["machine_status", "machine_id"]
) }}

SELECT *
FROM {{ ref('int_sensor_clean') }}

{% if is_incremental() %}
WHERE ingestion_time > (
    SELECT COALESCE(
        MAX(ingestion_time),
        (SELECT MIN(ingestion_time) FROM {{ ref('int_sensor_clean') }})
    )
    FROM {{ this }}
)
OR timestamp > (
    SELECT MAX(timestamp) - INTERVAL 1 HOUR
    FROM {{ this }}
)
{% endif %}