{{ config(materialized='table') }}

WITH base AS (
    SELECT *
    FROM {{ ref('fact_sensor') }}
)

SELECT
    timestamp,
    machine_id,
    machine_status,

    {{ sensor_feature_factory(target.schema ~ '_marts', 'fact_sensor') }}

FROM base

WINDOW w AS (
    PARTITION BY machine_id
    ORDER BY timestamp
    ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
)