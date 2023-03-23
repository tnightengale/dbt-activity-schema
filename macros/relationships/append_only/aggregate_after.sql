{% macro aggregate_after_join_clause(i) %}

{% set primary = dbt_activity_schema.primary %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} > {{ primary() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro aggregate_after(aggregation_func=dbt_activity_schema.count) %}

{% do return(namespace(
    name="aggregate_after",
    aggregation_func=aggregation_func,
    join_clause=dbt_activity_schema.aggregate_after_join_clause
)) %}

{% endmacro %}
