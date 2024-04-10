{% macro aggregate_after_join_clause(i, primary, appended) %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ appended }}.{{- columns.ts }} > {{ primary }}.{{- columns.ts }}
)
{% endmacro %}

{% macro aggregate_after(aggregation_func=dbt_activity_schema.count) %}

{% do return(namespace(
    name="aggregate_after",
    aggregation_func=aggregation_func,
    join_clause=dbt_activity_schema.aggregate_after_join_clause
)) %}

{% endmacro %}
