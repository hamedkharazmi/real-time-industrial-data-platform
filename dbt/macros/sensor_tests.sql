-- NULL RATIO TEST (ALL SENSORS)
{% macro sensor_null_ratio_test(model, threshold=0.3) %}

{% set sensors = get_sensor_columns(model) %}

{% for col in sensors %}

SELECT
  '{{ col }}' AS sensor,
  COUNTIF({{ col }} IS NULL) / COUNT(*) AS null_ratio
FROM {{ ref(model) }}
HAVING null_ratio > {{ threshold }}

{% if not loop.last %}UNION ALL{% endif %}

{% endfor %}

{% endmacro %}



-- ALL NULL SENSOR DETECTION
{% macro sensor_all_null_test(model) %}

{% set sensors = get_sensor_columns(model) %}

{% for col in sensors %}

SELECT '{{ col }}' AS sensor
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ ref(model) }}
    WHERE {{ col }} IS NOT NULL
)

{% if not loop.last %}UNION ALL{% endif %}

{% endfor %}

{% endmacro %}


-- SPIKE / ANOMALY DETECTION
{% macro sensor_spike_test(model, threshold=50) %}

{% set sensors = get_sensor_columns(model) %}

WITH base AS (
    SELECT *
    FROM {{ ref(model) }}
)

SELECT *
FROM (

{% for col in sensors %}

SELECT
  '{{ col }}' AS sensor,
  ABS({{ col }} - LAG({{ col }}) OVER (
      PARTITION BY machine_id ORDER BY timestamp
  )) AS delta
FROM base

{% if not loop.last %}UNION ALL{% endif %}

{% endfor %}

)
WHERE delta > {{ threshold }}

{% endmacro %}


-- SENSOR DRIFT TEST
{% macro sensor_drift_test(model, std_threshold=3) %}

{% set sensors = get_sensor_columns(model) %}

WITH stats AS (
  SELECT
    {% for col in sensors %}
    AVG({{ col }}) AS {{ col }}_avg,
    STDDEV({{ col }}) AS {{ col }}_std
    {% if not loop.last %},{% endif %}
    {% endfor %}
  FROM {{ ref(model) }}
)

SELECT *
FROM stats
WHERE
{% for col in sensors %}
ABS({{ col }}_avg) > {{ std_threshold }} * {{ col }}_std
{% if not loop.last %}OR{% endif %}
{% endfor %}

{% endmacro %}