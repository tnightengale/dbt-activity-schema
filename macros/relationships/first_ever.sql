{% macro first_ever(option, i) %}

{% set aggregation -%}
min
{%- endset %}

{% set join_clause -%}
(
    stream_{{ i }}.{{ dbt_activity_schema.columns().activity_occurrence }} = 1
)
{%- endset %}

{% set agg_or_join_mapping = dict(
    agg=aggregation,
    join=join_clause
) %}

{% do return(agg_or_join_mapping[option]) %}

{% endmacro %}
