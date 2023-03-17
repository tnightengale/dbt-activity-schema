{% macro aggregate_before_join_clause(i) %}

{% set stream = dbt_activity_schema.alias_stream %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ stream(i) }}.{{- columns.ts }} < {{ stream() }}.{{- columns.ts }}
)
{% endmacro %}

{% macro aggregate_before(aggregation_func=dbt_activity_schema.count) %}

{% do return(namespace(
    name="aggregate_before",
    aggregation_func=aggregation_func,
    join_clause=dbt_activity_schema.aggregate_before_join_clause
)) %}

{% endmacro %}
