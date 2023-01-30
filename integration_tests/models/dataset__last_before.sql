{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.primary_activity("All","bought something"),
        [
            dbt_activity_schema.append_activity("last_before", "visited page")
        ]
    )
}}
