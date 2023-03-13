{%- macro render_aggregation(col, activity) -%}
	{{ return(adapter.dispatch("render_aggregation", "dbt_activity_schema")(col, activity)) }}
{%- endmacro -%}


{%- macro default__render_aggregation(col, activity) -%}

{# Render the aggregation, handling special cases for non-cardinal columns.

params:

    col: str
        The column to aggregate.

    activity: activity (class)
        The activity class which contains a name and aggregation function.

#}

{% set columns = dbt_activity_schema.columns() %}
{% set aliased_col = dbt_activity_schema.generate_appended_column_alias(activity, col) %}
{% set aliased_activity_ts_col = dbt_activity_schema.generate_appended_column_alias(activity, columns.ts) %}

{# Handle non-cardinal feature_json aggregation by concating ts column. #}
{% if col in [columns.feature_json] %}

    {% set ts_concat_feature_json %}
        {% call activity.relationship.aggregation_func() %}
        {{ dbt.concat([aliased_activity_ts_col, aliased_col]) }}
        {% endcall %}
    {% endset %}

    {% set ts_aggregated %}
        {% call activity.relationship.aggregation_func() %}
        {{ aliased_activity_ts_col }}
        {% endcall %}
    {% endset %}

    {{ dbt_activity_schema.ltrim(ts_concat_feature_json, ts_aggregated) }} as {{ aliased_col }}

{% else %}
    {% call activity.relationship.aggregation_func() %}
    {{ aliased_col }}
    {% endcall %} as {{ aliased_col }}
{% endif %}

{% endmacro %}
