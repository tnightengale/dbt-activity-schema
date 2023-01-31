{% macro last_after_join_clause(i) %}
(
    stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} > stream.{{- dbt_activity_schema.columns().ts }} 
    and stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} <= coalesce(stream.{{- dbt_activity_schema.columns().activity_repeated_at }}, '2100-01-01'::timestamp)
)
{% endmacro %}

{% macro last_after() %}

{% do return(namespace(
    name="last_after",
    aggregation_func="max",
    join_clause=dbt_activity_schema.last_after_join_clause
)) %}

{% endmacro %}
