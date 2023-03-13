{%- macro render_aggregation(aggregation_func, col, activity) -%}
	{{ return(adapter.dispatch("render_aggregation", "dbt_activity_schema")(aggregation_func, col, activity)) }}
{%- endmacro -%}


{%- macro default__render_aggregation(aggregation_func, col, activity) -%}

{# Render the aggregation, handling special cases for non-cardinal columns.

params:

    aggregation_func: str
        A valid SQL aggregation function.

    col: str
        The column to aggregate.

    activity: str
        The activity to aggregate.

#}

{% set columns = dbt_activity_schema.columns() %}
{% set aliased_col = dbt_activity_schema.generate_appended_column_alias(activity, col) %}
{% set aliased_activity_ts_col = dbt_activity_schema.generate_appended_column_alias(activity, columns.ts) %}

{# Handle non-cardinal feature_json aggregation by concating ts column. #}
{% if col in [columns.feature_json] %}

    {% set ts_concat_feature_json %}
    (
        {{ aggregation_func }}(
            {{ dbt.concat([aliased_activity_ts_col, aliased_col]) }}
        )
    )
    {% endset %}

    {% set ts_aggregated %}
    {{ aggregation_func }}({{ aliased_activity_ts_col }})
    {% endset %}

    {{ dbt_activity_schema.ltrim(ts_concat_feature_json, ts_aggregated) }} as {{ aliased_col }}

{% else %}
    {{ aggregation_func }}( {{ aliased_col }} ) as {{ aliased_col }}
{% endif %}

{% endmacro %}
