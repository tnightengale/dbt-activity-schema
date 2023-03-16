{{
    dbt_activity_schema.dataset(
        ref("input__first_in_between"),
        dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(),
            "signed up",
            [
                "activity_id",
                "entity_uuid",
                "ts",
                "revenue_impact",
                "feature_json"
            ]
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_in_between(),
                "visit page",
                [
                    "feature_json",
                    "activity_occurrence",
                    "ts"
                ],
                additional_join_condition="
                json_extract({primary}.feature_json, 'type')
                = json_extract({appended}.feature_json, 'type')
                "
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.first_in_between(),
                "bought something",
                [
                    "activity_id",
                    "ts"
                ]
            )
        ]
    )
}}
