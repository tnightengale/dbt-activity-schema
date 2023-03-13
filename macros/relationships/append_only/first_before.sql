{% macro first_before_join_clause(i) %}

{% set stream = dbt_activity_schema.alias_stream %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ stream(i) }}.{{ columns.activity_occurrence }} = 1
    and {{ stream(i) }}.{{- columns.ts }} <= coalesce({{ stream() }}.{{- columns.activity_repeated_at }}, '2100-01-01'::timestamp)
)
{% endmacro %}


{% macro first_before_aggregation_func() %}
min({{ caller() }})
{% endmacro %}


{% macro first_before() %}

{% do return(namespace(
    name="first_before",
    aggregation_func=dbt_activity_schema.first_before_aggregation_func,
    join_clause=dbt_activity_schema.first_before_join_clause
)) %}

{% endmacro %}
