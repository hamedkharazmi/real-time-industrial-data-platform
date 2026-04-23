{% macro fill_sensor_gaps(dataset, table_name) %}

{% set sensors = get_sensor_columns(dataset, table_name, 'sensor_') %}

{% for col in sensors %}

LAST_VALUE({{ col }} IGNORE NULLS) OVER (
    PARTITION BY machine_id
    ORDER BY timestamp
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS {{ col }}

{% if not loop.last %},{% endif %}

{% endfor %}

{% endmacro %}