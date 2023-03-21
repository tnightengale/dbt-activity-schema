{%- macro render_aggregation(column_name, activity, i) -%}
	{{ return(adapter.dispatch("render_aggregation", "dbt_activity_schema")(column_name, activity, i)) }}
{%- endmacro -%}


{%- macro default__render_aggregation(column_name, activity, i) -%}

{# Render the aggregation, handling special cases for non-cardinal columns.

params:

    column_name: str
        The column to aggregate.

    activity: activity (class)
        The activity class which contains a name and aggregation function.

    i: int
        The ordinality of the appended activity in the list of all appended
        activities. Used to fully qualify the appended activity columns with an
        alias in the joins of dataset.sql.
#}

{% set columns = dbt_activity_schema.columns() %}
{% set qualified_col = dbt_activity_schema.alias_column(column_name, i) %}
{% set alias = dbt_activity_schema.alias_appended_activity(activity, column_name) %}

{#
    Handle min, max aggregations by prepending ts column, aggregating, then
    trimming. See here for details: https://tinyurl.com/36fuzjkd
#}

{% set aggregation %}
{# {{ print(activity.relationship.aggregation_func) }} #}
{% if activity.relationship.aggregation_func in [dbt_activity_schema.min, dbt_activity_schema.max] %}
    {{ print("if triggered") }}

    {% set qualified_ts_col = dbt_activity_schema.alias_column(columns.ts, i) %}
    {% set ts_concat_feature_json %}
        {% call activity.relationship.aggregation_func() %}
        {{ dbt.concat([qualified_ts_col, qualified_col]) }}
        {% endcall %}
    {% endset %}

    {% set ts_aggregated %}
        {% call activity.relationship.aggregation_func() %}
        {{ qualified_ts_col }}
        {% endcall %}
    {% endset %}

    {{ dbt_activity_schema.ltrim(ts_concat_feature_json, ts_aggregated) }} as {{ alias }}

{# Aggregate cardinal columns normally. #}
{% else %}
    {{ print("else triggered") }}
    {% call activity.relationship.aggregation_func() %}
    {{ qualified_col }}
    {% endcall %} as {{ alias }}
{% endif %}
{% endset %}

{% do return(aggregation) %}

{% endmacro %}
