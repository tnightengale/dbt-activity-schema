{% macro first_ever_join_clause(i) %}
(
    stream_{{ i }}.{{ dbt_activity_schema.columns().activity_occurrence }} = 1
)
{% endmacro %}

{% macro first_ever() %}

{% do return(namespace(
    name="first_ever",
    aggregation_func="min",
    join_clause=dbt_activity_schema.first_ever_join_clause
)) %}

{% endmacro %}
