{% macro last_before_join_clause(i) %}

{% set primary = dbt_activity_schema.primary %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} <= coalesce({{ primary() }}.{{- columns.ts }}, '1900-01-01'::timestamp)
)
{% endmacro %}

{% macro last_before() %}

{% do return(namespace(
    name="last_before",
    aggregation_func=dbt_activity_schema.max,
    join_clause=dbt_activity_schema.last_before_join_clause
)) %}

{% endmacro %}
