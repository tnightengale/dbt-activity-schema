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

{# Update names using the `override_columns` project but keep keys according to
the Activity Schema V2 specification. #}
{% do column_names.update(var("override_columns", {})) %}

{% do return(column_names) %}

{% endmacro %}
