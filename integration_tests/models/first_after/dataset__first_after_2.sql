{{
    dbt_activity_schema.dataset(
        ref("input__first_after"),
        dbt_activity_schema.primary_activity("All","visit page"),
        [
            dbt_activity_schema.append_activity(
                "first_after", "bought something")
        ]
    )
}}
