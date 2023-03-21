{% macro last_after_join_clause(i) %}

{% set stream = dbt_activity_schema.stream %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} > {{ stream() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro last_after() %}

{% do return(namespace(
    name="last_after",
    aggregation_func=dbt_activity_schema.max,
    join_clause=dbt_activity_schema.last_after_join_clause
)) %}

{% endmacro %}
