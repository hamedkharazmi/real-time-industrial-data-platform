{% macro sensor_feature_factory(table_name) %}

{% set sensors = get_sensor_columns(table_name, 'sensor_') %}

{% for col in sensors %}

-- =========================
-- RAW VALUE
-- =========================
{{ col }},

-- =========================
-- ROLLING MEAN
-- =========================
AVG({{ col }}) OVER w AS {{ col }}_avg_20,

-- =========================
-- ROLLING STD
-- =========================
STDDEV({{ col }}) OVER w AS {{ col }}_std_20,

-- =========================
-- Z-SCORE (ANOMALY SIGNAL)
-- =========================
SAFE_DIVIDE(
    {{ col }} - AVG({{ col }}) OVER w,
    STDDEV({{ col }}) OVER w
) AS {{ col }}_zscore,

-- =========================
-- DELTA (TREND)
-- =========================
{{ col }} - LAG({{ col }}) OVER (
    PARTITION BY machine_id
    ORDER BY timestamp
) AS {{ col }}_delta

{% if not loop.last %},{% endif %}

{% endfor %}

{% endmacro %}