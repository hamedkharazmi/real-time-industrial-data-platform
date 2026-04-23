WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'sensor_raw') }}
),

renamed AS (
    SELECT
        -- drop useless column
        * EXCEPT(`int64_field_0`),

        -- timestamp conversion
        TIMESTAMP(timestamp) AS timestamp_converted
    FROM source_data
),

typed AS (
    SELECT
        timestamp_converted AS timestamp,
        ingestion_time,
        machine_id,
        machine_status,

        {% set sensors = get_sensor_columns(source('raw','sensor_raw').schema, 'sensor_raw', 'sensor_') %}

        {% for col in sensors %}
        SAFE_CAST({{ col }} AS FLOAT64) AS {{ col }}
        {% if not loop.last %},{% endif %}
        {% endfor %}

        -- -- cast all sensors
        -- SAFE_CAST(sensor_00 AS FLOAT64) AS sensor_00,
        -- SAFE_CAST(sensor_01 AS FLOAT64) AS sensor_01,
        -- SAFE_CAST(sensor_02 AS FLOAT64) AS sensor_02,
        -- SAFE_CAST(sensor_03 AS FLOAT64) AS sensor_03,
        -- SAFE_CAST(sensor_04 AS FLOAT64) AS sensor_04,
        -- SAFE_CAST(sensor_05 AS FLOAT64) AS sensor_05,
        -- SAFE_CAST(sensor_06 AS FLOAT64) AS sensor_06,
        -- SAFE_CAST(sensor_07 AS FLOAT64) AS sensor_07,
        -- SAFE_CAST(sensor_08 AS FLOAT64) AS sensor_08,
        -- SAFE_CAST(sensor_09 AS FLOAT64) AS sensor_09,
        -- SAFE_CAST(sensor_10 AS FLOAT64) AS sensor_10,
        -- SAFE_CAST(sensor_11 AS FLOAT64) AS sensor_11,
        -- SAFE_CAST(sensor_12 AS FLOAT64) AS sensor_12,
        -- SAFE_CAST(sensor_13 AS FLOAT64) AS sensor_13,
        -- SAFE_CAST(sensor_14 AS FLOAT64) AS sensor_14,
        -- SAFE_CAST(sensor_15 AS FLOAT64) AS sensor_15,
        -- SAFE_CAST(sensor_16 AS FLOAT64) AS sensor_16,
        -- SAFE_CAST(sensor_17 AS FLOAT64) AS sensor_17,
        -- SAFE_CAST(sensor_18 AS FLOAT64) AS sensor_18,
        -- SAFE_CAST(sensor_19 AS FLOAT64) AS sensor_19,
        -- SAFE_CAST(sensor_20 AS FLOAT64) AS sensor_20,
        -- SAFE_CAST(sensor_21 AS FLOAT64) AS sensor_21,
        -- SAFE_CAST(sensor_22 AS FLOAT64) AS sensor_22,
        -- SAFE_CAST(sensor_23 AS FLOAT64) AS sensor_23,
        -- SAFE_CAST(sensor_24 AS FLOAT64) AS sensor_24,
        -- SAFE_CAST(sensor_25 AS FLOAT64) AS sensor_25,
        -- SAFE_CAST(sensor_26 AS FLOAT64) AS sensor_26,
        -- SAFE_CAST(sensor_27 AS FLOAT64) AS sensor_27,
        -- SAFE_CAST(sensor_28 AS FLOAT64) AS sensor_28,
        -- SAFE_CAST(sensor_29 AS FLOAT64) AS sensor_29,
        -- SAFE_CAST(sensor_30 AS FLOAT64) AS sensor_30,
        -- SAFE_CAST(sensor_31 AS FLOAT64) AS sensor_31,
        -- SAFE_CAST(sensor_32 AS FLOAT64) AS sensor_32,
        -- SAFE_CAST(sensor_33 AS FLOAT64) AS sensor_33,
        -- SAFE_CAST(sensor_34 AS FLOAT64) AS sensor_34,
        -- SAFE_CAST(sensor_35 AS FLOAT64) AS sensor_35,
        -- SAFE_CAST(sensor_36 AS FLOAT64) AS sensor_36,
        -- SAFE_CAST(sensor_37 AS FLOAT64) AS sensor_37,
        -- SAFE_CAST(sensor_38 AS FLOAT64) AS sensor_38,
        -- SAFE_CAST(sensor_39 AS FLOAT64) AS sensor_39,
        -- SAFE_CAST(sensor_40 AS FLOAT64) AS sensor_40,
        -- SAFE_CAST(sensor_41 AS FLOAT64) AS sensor_41,
        -- SAFE_CAST(sensor_42 AS FLOAT64) AS sensor_42,
        -- SAFE_CAST(sensor_43 AS FLOAT64) AS sensor_43,
        -- SAFE_CAST(sensor_44 AS FLOAT64) AS sensor_44,
        -- SAFE_CAST(sensor_45 AS FLOAT64) AS sensor_45,
        -- SAFE_CAST(sensor_46 AS FLOAT64) AS sensor_46,
        -- SAFE_CAST(sensor_47 AS FLOAT64) AS sensor_47,
        -- SAFE_CAST(sensor_48 AS FLOAT64) AS sensor_48,
        -- SAFE_CAST(sensor_49 AS FLOAT64) AS sensor_49,
        -- SAFE_CAST(sensor_50 AS FLOAT64) AS sensor_50,
        -- SAFE_CAST(sensor_51 AS FLOAT64) AS sensor_51,

    FROM renamed
),

-- Remove duplicates and keep the most recent record per sensor reading
deduped AS (
    SELECT *
    FROM typed
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY machine_id, timestamp
        ORDER BY ingestion_time DESC
    ) = 1
)

SELECT *
FROM deduped