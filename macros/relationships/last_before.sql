{% macro last_before_join_clause(i) %}
(
    stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} <= coalesce(stream.{{- dbt_activity_schema.columns().ts }}, '1900-01-01'::timestamp)
)
{% endmacro %}

{% macro last_before() %}

{% do return(namespace(
    name="last_before",
    aggregation_func="max",
    join_clause=dbt_activity_schema.last_before_join_clause
)) %}

{% endmacro %}
