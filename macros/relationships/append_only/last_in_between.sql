{% macro last_in_between_join_clause(i) %}

{% set stream = dbt_activity_schema.stream %}
{% set columns = dbt_activity_schema.columns() %}
{% set appended = dbt_activity_schema.appended %}

(
    {{ appended() }}.{{- columns.ts }} > {{ stream() }}.{{- columns.ts }}
    and (
        {{ appended() }}.{{- columns.ts }} <= {{ stream() }}.{{- columns.activity_repeated_at }}
        or {{ stream() }}.{{- columns.activity_repeated_at }} is null
    )
)
{% endmacro %}

{% macro last_in_between() %}

{% do return(namespace(
    name="last_in_between",
    aggregation_func=dbt_activity_schema.max,
    join_clause=dbt_activity_schema.last_in_between_join_clause
)) %}

{% endmacro %}
