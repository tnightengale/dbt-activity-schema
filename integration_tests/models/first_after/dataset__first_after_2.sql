{{
    dbt_activity_schema.dataset(
        ref("input__first_after"),
        dbt_activity_schema.primary_activity(
            dbt_activity_schema.occurance("all"),
            "visit page"
        ),
        [
            dbt_activity_schema.appended_activity(
                dbt_activity_schema.relationship("first_after"),
                "bought something"
            )
        ]
    )
}}
