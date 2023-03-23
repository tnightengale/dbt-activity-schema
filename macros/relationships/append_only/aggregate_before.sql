{% macro aggregate_before_join_clause(i) %}

{% set primary = dbt_activity_schema.primary %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} < {{ primary() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro aggregate_before(aggregation_func=dbt_activity_schema.count) %}

{% do return(namespace(
    name="aggregate_before",
    aggregation_func=aggregation_func,
    join_clause=dbt_activity_schema.aggregate_before_join_clause
)) %}

{% endmacro %}
