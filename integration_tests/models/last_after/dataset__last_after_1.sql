{{
    dbt_activity_schema.dataset(
        ref("input__last_after"),
        dbt_activity_schema.primary_activity(dbt_activity_schema.occurance(1),"signed up"),
        [
            dbt_activity_schema.appended_activity(dbt_activity_schema.relationship("last_after"), "visit page")
        ]
    )
}}
s
