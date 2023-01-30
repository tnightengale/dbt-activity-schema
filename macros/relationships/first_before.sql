{% macro first_before_join_clause(i) %}
(
    stream_{{ i }}.{{ dbt_activity_schema.columns().activity_occurrence }} = 1
    and stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} <= coalesce(stream.{{- dbt_activity_schema.columns().activity_repeated_at }}, '2100-01-01'::timestamp)
)
{% endmacro %}

{% macro first_before() %}

{% do return(namespace(
    name="first_before",
    aggregation_func="min",
    join_clause=dbt_activity_schema.first_before_join_clause
)) %}

{% endmacro %}
