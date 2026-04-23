SELECT
    timestamp,
    ingestion_time,
    machine_id,
    machine_status,
    {{ fill_sensor_gaps(target.schema ~ '_staging', 'stg_sensor') }}

FROM {{ ref('stg_sensor') }}