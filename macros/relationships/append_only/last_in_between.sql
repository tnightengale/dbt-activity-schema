{% macro last_in_between_join_clause(i, primary, appended) %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ appended }}.{{- columns.ts }} > {{ primary }}.{{- columns.ts }}
    and (
        {{ appended }}.{{- columns.ts }} <= {{ primary }}.{{- columns.activity_repeated_at }}
        or {{ primary }}.{{- columns.activity_repeated_at }} is null
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
