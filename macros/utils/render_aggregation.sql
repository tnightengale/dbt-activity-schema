{% macro render_aggregation(aggregation_func, col, activity) %}

{# Render the aggregation, handling special cases for non-cardinal columns.

params:

    aggregation_func: str
        A valid SQL aggregation function.

    col: str
        The column to aggregate.

    activity: str
        The activity to aggregate.

#}

{% set aliased_col = dbt_activity_schema.generate_appended_column_alias(activity, col) %}
{% set columns = dbt_activity_schema.columns() %}

{# Handle non-cardinal feature_json aggregation #}
{% if col == columns.feature_json %}
    (
        {{ aggregation_func }}(
            case
                when {{ columns.ts }} = {{ aggregation_func }}({{ columns.ts }})
                    then {{ aliased_col }}
            end
        )
    ) as {{ aliased_col }}
{% else %}
    {{ aggregation_func }}( {{ aliased_col }} ) as {{ aliased_col }}
{% endif %}

{% endmacro %}
