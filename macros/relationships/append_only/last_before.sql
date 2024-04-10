{% macro last_before_join_clause(i, primary, appended) %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ appended }}.{{- columns.ts }} <= coalesce({{ primary }}.{{- columns.ts }}, '1900-01-01'::timestamp)
)
{% endmacro %}

{% macro last_before() %}

{% do return(namespace(
    name="last_before",
    aggregation_func=dbt_activity_schema.max,
    join_clause=dbt_activity_schema.last_before_join_clause
)) %}

{% endmacro %}
