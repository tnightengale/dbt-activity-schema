{% macro _min_or_max(min_or_max, qualified_col) %}
    {{ return(adapter.dispatch('_min_or_max','dbt_activity_schema')(min_or_max, qualified_col)) }}
{%- endmacro -%}

{% macro default___min_or_max(min_or_max, qualified_col) -%}

{% set aggregation = "min" if min_or_max == "min" else "max" %}
{% set column_name = qualified_col.split(".")[-1].strip() %}
{% set qualified_ts_col = "{}.{}".format(dbt_activity_schema.appended(), dbt_activity_schema.columns().ts )%}
{% set columns = dbt_activity_schema.columns() %}


{# Set type to cast back to after aggregation. #}
{# TODO: Refactor column abstraction to contain types. #}
{% if column_name in [
    columns.ts,
    columns.activity_repeated_at
] %}
    {% set type = dbt.type_timestamp() %}
{% elif column_name in [
    columns.activity_occurrence,
    columns.revenue_impact
] %}
    {% set type = dbt.type_numeric() %}
{% else %}
    {% set type = dbt.type_string() %}
{% endif %}

{# Prepend ts column and aggregate. See here for details: https://tinyurl.com/mwfz6xm4 #}
{% set ts_concatenated_and_aggregated_col %}
    {{ aggregation }}(
        {{ dbt.concat([
            dbt.safe_cast(qualified_ts_col, dbt.type_string()),
            dbt.safe_cast(qualified_col, dbt.type_string())
            ]) }}
        )
{% endset %}

{# Aggregate ts column before trimming, so it is not required in GROUP BY. #}
{% set aggregated_ts_col %}
    {{ aggregation }}( {{ dbt.safe_cast(qualified_ts_col, dbt.type_string()) }} )
{% endset %}

{# Calculate length of column without prepended & aggregated ts column. #}
{% set retain_n_rightmost_characters %}
{{ dbt.length(ts_concatenated_and_aggregated_col) }} - {{ dbt.length(aggregated_ts_col) }}
{% endset %}

{# Remove prepended & aggregated ts column. #}
{% set output %}
{{ dbt.safe_cast(
    dbt.right(
        ts_concatenated_and_aggregated_col,
        retain_n_rightmost_characters
    ), type) }}
{% endset %}

{% do return(output) %}

{% endmacro %}

{% macro snowflake___min_or_max(min_or_max, qualified_col) -%}
{% set aggregation = "min_by" if min_or_max == "min" else "max_by" %}
{% set qualified_ts_col = "{}.{}".format(
    dbt_activity_schema.appended(), dbt_activity_schema.columns().ts
) %}

{# Apply min or max by to the selected column. #}
{% set aggregated_col %}
        {{ aggregation }}({{ qualified_col }}, {{ qualified_ts_col }})
{% endset %}

{# Return output. #}
{% do return(aggregated_col) %}
{%- endmacro %}