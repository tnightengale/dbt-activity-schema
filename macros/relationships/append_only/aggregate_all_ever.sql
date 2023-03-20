{% macro aggregate_all_ever_join_clause(i) %}
(true)
{% endmacro %}

{% macro aggregate_all_ever(aggregation_func=dbt_activity_schema.count) %}

{% do return(namespace(
    name="aggregate_all_ever",
    aggregation_func=aggregation_func,
    join_clause=dbt_activity_schema.aggregate_all_ever_join_clause
)) %}

{% endmacro %}
