{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.primary_activity("All","signed up"),
        [
            dbt_activity_schema.append_activity("first_in_between", "bought something")
        ]
    )
}}
