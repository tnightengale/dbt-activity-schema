{% macro first_after_join_clause(i) %}
(
    stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} > stream.{{- dbt_activity_schema.columns().ts }} 
    and (
        stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} <= stream.{{- dbt_activity_schema.columns().activity_repeated_at }}
        or stream.{{- dbt_activity_schema.columns().activity_repeated_at }} is null
    )
)
{% endmacro %}

{% macro first_after() %}

{% do return(namespace(
    name="first_after",
    aggregation_func="min",
    join_clause=dbt_activity_schema.first_after_join_clause
)) %}

{% endmacro %}
