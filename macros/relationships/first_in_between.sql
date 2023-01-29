{% macro first_in_between_join_clause(i) %}
(
    stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} > stream.{{- dbt_activity_schema.columns().ts }} 
    and stream_{{ i -}}.{{- dbt_activity_schema.columns().ts }} <= coalesce(stream.{{- dbt_activity_schema.columns().activity_repeated_at }}, '2100-01-01'::timestamp)
    and stream_{{ i }}.{{- dbt_activity_schema.columns().activity_occurrence }} = 1
)
{# TODO: Determine if activities without a first in between should drop out #}
{% endmacro %}

{% macro first_in_between(i) %}

{% do return(namespace(
    name="first_in_between",
    aggregation_func="min",
    join_clause=dbt_activity_schema.first_in_between_join_clause
)) %}

{% endmacro %}
