{% macro get_sensor_columns(dataset, table_name, prefix='sensor_') %}

{% set query %}
    SELECT column_name
    FROM `{{ target.project }}.{{ dataset }}.INFORMATION_SCHEMA.COLUMNS`
    WHERE table_name = '{{ table_name }}'
    AND column_name LIKE '{{ prefix }}%'
    ORDER BY column_name
{% endset %}

{% set results = run_query(query) %}

{% if execute %}
    {% set columns = results.columns[0].values() %}
{% else %}
    {% set columns = [] %}
{% endif %}

{{ return(columns) }}

{% endmacro %}