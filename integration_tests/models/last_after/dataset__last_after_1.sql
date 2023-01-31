{{
    dbt_activity_schema.dataset(
        ref("input__last_after"),
        dbt_activity_schema.primary_activity(1,"signed up"),
        [
            dbt_activity_schema.append_activity("last_after", "visit page")
        ]
    )
}}
s
