{% macro first_after_join_clause(i) %}

{% set primary = dbt_activity_schema.primary %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} > {{ primary() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro first_after() %}

{% do return(namespace(
    name="first_after",
    aggregation_func=dbt_activity_schema.min,
    join_clause=dbt_activity_schema.first_after_join_clause
)) %}

{% endmacro %}
