{% macro fill_sensor_gaps(table_name) %}

{% set sensors = get_sensor_columns(table_name, 'sensor_') %}

{% for col in sensors %}

-- stable forward-fill
MAX({{ col }}) OVER (
    PARTITION BY machine_id
    ORDER BY timestamp
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS {{ col }}_filled

{% if not loop.last %},{% endif %}

{% endfor %}

{% endmacro %}