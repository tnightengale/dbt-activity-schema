{{
    dbt_activity_schema.dataset(
        ref("example_activity_stream"),
        dbt_activity_schema.primary_activity("All","visited page"),
        [
            dbt_activity_schema.append_activity("first_ever", "signed up")
        ]
    )
}}
