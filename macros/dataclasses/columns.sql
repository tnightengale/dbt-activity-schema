{% macro columns() %}
	{{ return(adapter.dispatch("columns", "dbt_activity_schema")())}}
{% endmacro %}

{% macro default__columns() %}

{% set activity_schema_required_column_aliases = var(
    "activity_schema_required_column_aliases",
    dict(
        ts = "ts",
        customer = "customer",
        activity = "activity",
        activity_occurrence = "activity_occurrence",
        activity_repeated_at = "activity_repeated_at"
    )
) %}

{% set required_columns = [
    "ts",
    "customer",
    "activity",
    "activity_occurrence",
    "activity_repeated_at"
] %}

{% set required_columns_provided = activity_schema_required_column_aliases.keys() | list %}
{% if required_columns_provided != required_columns %}
    {% set message %}
    "Project variable 'activity_schema_required_column_aliases' must contain the following keys: " {{ required_columns }},
    "Got: " {{ required_columns_provided }}
    {% endset %}
    {{ exceptions.raise_compiler_error(message)}}
{% endif %}

{% set activity_schema_primary_activity_columns = var(
    "activity_schema_primary_activity_columns",
    [
        "activity_id",
        "activity",
        "anonymous_customer_id",
        "feature_json",
        "revenue_impact",
        "link"
    ]
) %}

{% set activity_schema_appended_activities_columns = var(
    "activity_schema_appended_activities_columns",
    [
        dict(
            name = "feature_json",
            aggregation = "min"
        ),
        dict(
            name = "ts",
            aggregation = "min"
        )
    ]
) %}

{% do return(namespace(
    ts = activity_schema_required_column_aliases["ts"],
    customer = activity_schema_required_column_aliases["customer"],
    activity = activity_schema_required_column_aliases["activity"],
    activity_occurrence = activity_schema_required_column_aliases["activity_occurrence"],
    activity_repeated_at = activity_schema_required_column_aliases["activity_repeated_at"],
    primary_activity = activity_schema_primary_activity_columns,
    appended_activities = activity_schema_appended_activities_columns
)) %}

{% endmacro %}
