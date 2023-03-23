{{
    dbt_activity_schema.dataset(
        ref("input__aggregate_after"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "signed up"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_after(),
                "visit page",
                ["activity_id"]
            )
        ]
    )
}}
