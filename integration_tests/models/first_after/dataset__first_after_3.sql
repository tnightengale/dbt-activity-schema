{{
    dbt_activity_schema.dataset(
        ref("input__first_after"),
        dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(),
            "signed up"
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_after(),
                "visit page",
                ["feature_json", "activity_occurrence", "ts"],
                additional_join_condition="
                json_extract({primary}.feature_json, 'type')
                = json_extract({appended}.feature_json, 'type')
                "
            )
        ]
    )
}}
