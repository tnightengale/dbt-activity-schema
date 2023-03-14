{% macro all_ever_join_clause() %}
(true)
{% endmacro %}

{% macro all_ever() %}

{% do return(namespace(
    name="all_ever",
    aggregation_func=dbt_activity_schema.min,
    join_clause=dbt_activity_schema.all_ever_join_clause,
    where_clause=dbt_activity_schema.all_ever_join_clause()
)) %}

{% endmacro %}
