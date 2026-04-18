-- {% macro sensor_feature_factory(dataset, table_name) %}

-- {% set sensors = get_sensor_columns(dataset, table_name, 'sensor_') %}

-- {% for col in sensors %}

-- {{ col }},

-- AVG({{ col }}) OVER w AS {{ col }}_avg_20,
-- STDDEV({{ col }}) OVER w AS {{ col }}_std_20,

-- SAFE_DIVIDE(
--     {{ col }} - AVG({{ col }}) OVER w,
--     STDDEV({{ col }}) OVER w
-- ) AS {{ col }}_zscore,

-- {{ col }} - LAG({{ col }}) OVER (
--     PARTITION BY machine_id
--     ORDER BY timestamp
-- ) AS {{ col }}_delta

-- {% if not loop.last %},{% endif %}

-- {% endfor %}

-- {% endmacro %}

{% macro sensor_feature_factory(dataset, table_name) %}

{% set sensors = get_sensor_columns(dataset, table_name, 'sensor_') %}

{% for col in sensors %}

{{ col }},

AVG({{ col }}) OVER w AS {{ col }}_avg_20,
STDDEV({{ col }}) OVER w AS {{ col }}_std_20,

SAFE_DIVIDE(
    {{ col }} - AVG({{ col }}) OVER w,
    STDDEV({{ col }}) OVER w
) AS {{ col }}_zscore,

{{ col }} - LAG({{ col }}) OVER (
    PARTITION BY machine_id
    ORDER BY timestamp
) AS {{ col }}_delta

{% if not loop.last %},{% endif %}

{% endfor %}

{% endmacro %}