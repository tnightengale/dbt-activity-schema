{% macro first_after_join_clause(i, primary, appended) %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ appended }}.{{- columns.ts }} > {{ primary }}.{{- columns.ts }}
)
{% endmacro %}

{% macro first_after() %}

{% do return(namespace(
    name="first_after",
    aggregation_func=dbt_activity_schema.min,
    join_clause=dbt_activity_schema.first_after_join_clause
)) %}

{% endmacro %}
