{% macro aggregate_in_before_join_clause(i) %}

{% set stream = dbt_activity_schema.generate_stream_alias %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ stream(i) }}.{{- columns.ts }} < {{ stream() }}.{{- columns.ts }}
)
{% endmacro %}


{% macro aggregate_in_before_aggregation_func() %}
count(distinct {{ caller() }} )
{% endmacro %}


{% macro aggregate_in_before() %}

{% do return(namespace(
    name="aggregate_in_before",
    aggregation_func=dbt_activity_schema.aggregate_in_before_aggregation_func,
    join_clause=dbt_activity_schema.aggregate_in_before_join_clause
)) %}

{% endmacro %}
