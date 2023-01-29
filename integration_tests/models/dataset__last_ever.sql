{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.primary_activity("Last","visited page"),
        [
            dbt_activity_schema.append_activity("last_ever", "bought something")
        ]
    )
}}
