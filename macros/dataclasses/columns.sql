{% macro columns() %}
	{{ return(adapter.dispatch("columns", "dbt_activity_schema")())}}
{% endmacro %}

{% macro default__columns() %}

{% do return(namespace(
    activity_id = var("activity_stream_activity_id_col_name", "activity_id"),
    ts = var("activity_stream_ts_col_name", "ts"),
    customer = var("activity_stream_customer_col_name", "customer"),
    activity = var("activity_stream_activity_col_name", "activity"),
    anonymous_customer_id = var("activity_stream_anonymous_customer_id_col_name", "anonymous_customer_id"),
    feature_json = var("activity_stream_feature_json_col_name", "feature_json"),
    revenue_impact = var("activity_stream_revenue_impact_col_name", "revenue_impact"),
    link = var("activity_stream_link_col_name", "link"),
    activity_occurrence = var("activity_stream_activity_occurrence_col_name", "activity_occurrence"),
    activity_repeated_at = var("activity_stream_activity_repeated_at_col_name", "activity_repeated_at")
)) %}

{% endmacro %}
