{{
    dbt_activity_schema.dataset(
        ref("input__first_after"),
        dbt_activity_schema.primary_activity("All","signed up"),
        [
            dbt_activity_schema.append_activity(
                "first_after",
                "visit page",
                ["feature_json", "activity_occurrence", "ts"],
                feature_json_join_columns=["type"]
            )
        ]
    )
}}
