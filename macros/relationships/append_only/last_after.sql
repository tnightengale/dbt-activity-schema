{% macro last_after_join_clause(i) %}

{% set primary = dbt_activity_schema.primary %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} > {{ primary() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro last_after() %}

{% do return(namespace(
    name="last_after",
    aggregation_func=dbt_activity_schema.max,
    join_clause=dbt_activity_schema.last_after_join_clause
)) %}

{% endmacro %}
