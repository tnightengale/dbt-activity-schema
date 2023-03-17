{% macro aggregate_after_join_clause(i) %}

{% set stream = dbt_activity_schema.alias_stream %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ stream(i) }}.{{- columns.ts }} > {{ stream() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro aggregate_after(aggregation_func=dbt_activity_schema.count) %}

{% do return(namespace(
    name="aggregate_after",
    aggregation_func=aggregation_func,
    join_clause=dbt_activity_schema.aggregate_after_join_clause
)) %}

{% endmacro %}
