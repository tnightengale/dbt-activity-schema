{% macro last_in_between_join_clause(i) %}

{% set stream = dbt_activity_schema.alias_stream %}
{% set columns = dbt_activity_schema.columns() %}

(
    {{ stream(i) }}.{{- columns.ts }} > {{ stream() }}.{{- columns.ts }}
    and (
        {{ stream(i) }}.{{- columns.ts }} <= {{ stream() }}.{{- columns.activity_repeated_at }}
        or {{ stream() }}.{{- columns.activity_repeated_at }} is null
    )
)
{% endmacro %}


{% macro last_in_between_aggregation_func() %}
max({{ caller() }})
{% endmacro %}


{% macro last_in_between() %}

{% do return(namespace(
    name="last_in_between",
    aggregation_func=dbt_activity_schema.last_in_between_aggregation_func,
    join_clause=dbt_activity_schema.last_in_between_join_clause
)) %}

{% endmacro %}
