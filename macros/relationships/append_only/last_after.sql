{% macro last_after_join_clause(i, primary, appended) %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ appended }}.{{- columns.ts }} > {{ primary }}.{{- columns.ts }}
)
{% endmacro %}

{% macro last_after() %}

{% do return(namespace(
    name="last_after",
    aggregation_func=dbt_activity_schema.max,
    join_clause=dbt_activity_schema.last_after_join_clause
)) %}

{% endmacro %}
