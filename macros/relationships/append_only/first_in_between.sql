{% macro first_in_between_join_clause(i) %}

{% set primary = dbt_activity_schema.primary %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} > {{ primary() }}.{{- columns.ts }}
    and (
        {{ appended() }}.{{- columns.ts }} <= {{ primary() }}.{{- columns.activity_repeated_at }}
        or {{ primary() }}.{{- columns.activity_repeated_at }} is null
    )
)
{% endmacro %}

{% macro first_in_between() %}

{% do return(namespace(
    name="first_in_between",
    aggregation_func=dbt_activity_schema.min,
    join_clause=dbt_activity_schema.first_in_between_join_clause
)) %}

{% endmacro %}
