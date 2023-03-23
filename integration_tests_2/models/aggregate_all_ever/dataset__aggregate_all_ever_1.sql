{{
    dbt_activity_schema.dataset(
        ref("input__aggregate_all_ever"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "signed up"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_all_ever(),
                "visit page",
                ["activity_id"]
            )
        ]
    )
}}
