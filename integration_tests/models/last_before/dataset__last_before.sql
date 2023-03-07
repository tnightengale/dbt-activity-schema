{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.primary_activity(dbt_activity_schema.occurance("all"),"bought something"),
        [
            dbt_activity_schema.appended_activity(dbt_activity_schema.relationship("last_before"), "visited page")
        ]
    )
}}
