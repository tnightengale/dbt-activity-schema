{% macro columns() %}
	{{ return(adapter.dispatch("columns", "dbt_activity_schema")())}}
{% endmacro %}

{% macro default__columns() %}

{% set column_names =
    dict(
        activity_id = "activity_id",
        ts = "ts",
        customer = "customer",
        anonymous_customer_id = "anonymous_customer_id",
        activity = "activity",
        activity_occurrence = "activity_occurrence",
        activity_repeated_at = "activity_repeated_at",
        feature_json = "feature_json",
        revenue_impact = "revenue_impact",
        link = "link"
    )
%}

{% do column_names.update(var("column_names", {})) %}


{% set primary_activity_columns = var("primary_activity_columns", column_names.values() | list) %}

{% set appended_activity_columns = var("appended_activity_columns", column_names.values() | list) %}

{% do return(namespace(
    activity_id = column_names["activity_id"],
    ts = column_names["ts"],
    customer = column_names["customer"],
    anonymous_customer_id = column_names["anonymous_customer_id"],
    activity = column_names["activity"],
    activity_occurrence = column_names["activity_occurrence"],
    activity_repeated_at = column_names["activity_repeated_at"],
    feature_json = column_names["feature_json"],
    revenue_impact = column_names["revenue_impact"],
    link = column_names["link"],
    primary_activity = primary_activity_columns,
    appended_activities = appended_activity_columns
)) %}

{% endmacro %}
