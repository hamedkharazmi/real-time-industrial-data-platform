SELECT
    *,

    {{ fill_sensor_gaps('stg_sensor') }}

FROM {{ ref('stg_sensor') }}