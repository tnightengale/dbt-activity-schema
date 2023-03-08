{% macro nth_ever_join_clause(nth_occurance, i=none) %}
(
    {{ dbt_activity_schema.generate_stream_alias(i) }}.{{ dbt_activity_schema.columns().activity_occurrence }} = {{ nth_occurance }}
)
{% endmacro %}

{% macro nth_ever(nth_occurance) %}

{% do return(namespace(
    name="nth_ever",
    aggregation_func="min",
    nth_occurance=nth_occurance,
    join_clause=dbt_activity_schema.nth_ever_join_clause,
    where_clause=dbt_activity_schema.nth_ever_join_clause(nth_occurance)
)) %}

{% endmacro %}
