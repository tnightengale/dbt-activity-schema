{% macro nth_ever_join_clause(nth_occurance, alias=dbt_activity_schema.appended()) %}
(
    {{ alias }}.{{ dbt_activity_schema.columns().activity_occurrence }} = {{ nth_occurance }}
)
{% endmacro %}

{% macro nth_ever(nth_occurance) %}

{% do return(namespace(
    name="nth_ever",
    aggregation_func=dbt_activity_schema.min,
    nth_occurance=nth_occurance,
    join_clause=dbt_activity_schema.nth_ever_join_clause,
    where_clause=dbt_activity_schema.nth_ever_join_clause(nth_occurance, dbt_activity_schema.primary())
)) %}

{% endmacro %}
