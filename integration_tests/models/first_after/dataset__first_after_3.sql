{{
    dbt_activity_schema.dataset(
        ref("input__first_after"),
        dbt_activity_schema.primary_activity(
            dbt_activity_schema.occurance("all"),
            "signed up"
        ),
        [
            dbt_activity_schema.appended_activity(
                dbt_activity_schema.relationship("first_after"),
                "visit page",
                ["feature_json", "activity_occurrence", "ts"],
                additional_join_condition="
                json_extract({stream}.feature_json, 'type')
                = json_extract({joined}.feature_json, 'type')
                "
            )
        ]
    )
}}
