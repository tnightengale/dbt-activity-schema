{% macro first_before_join_clause(i, primary, appended) %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ appended }}.{{ columns.activity_occurrence }} = 1
    and {{ appended }}.{{- columns.ts }} <= coalesce({{ primary }}.{{- columns.activity_repeated_at }}, '2100-01-01'::timestamp)
)
{% endmacro %}

{% macro first_before() %}

{% do return(namespace(
    name="first_before",
    aggregation_func=dbt_activity_schema.min,
    join_clause=dbt_activity_schema.first_before_join_clause
)) %}

{% endmacro %}
