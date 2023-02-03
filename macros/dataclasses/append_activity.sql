{% macro append_activity(
    relationship_name,
    activity_name,
    override_appended_columns=[],
    feature_json_join_columns=[]
) %}

{# An activity to append to the `primary_activity`.

params:

    relationship_name: str (enum)
        The string identifier of the defined activity relationship, one of;
            1. "first_ever"
            2. "last_ever"
            3. "first_before"
            4. "last_before"
            5. "first_after"
            6. "last_after"
            7. "aggregate_after"
            8. "aggregate_all_ever"

    activity_name: str
        The string identifier of the activity in the stream to append (join).

    override_appended_columns: List[str]
        List of columns to join to the primary activity, defaults to the project var `appended_activity_columns`.

    feature_json_join_columns: List[str]
        List of additional keys in the feature_json to extract and join on.
#}

{% set default_appended_activity_columns = dbt_activity_schema.columns().appended_activities %}

{% set columns_to_append = override_appended_columns if override_appended_columns != [] else default_appended_activity_columns %}

{% set relationship_factory = dict(
    first_before = dbt_activity_schema.first_before(),
    first_ever = dbt_activity_schema.first_ever(),
    last_before = dbt_activity_schema.last_before(),
    last_ever = dbt_activity_schema.last_ever(),
    first_after = dbt_activity_schema.first_after(),
    last_after = dbt_activity_schema.last_after()
) %}

{% do return(namespace(
    name = activity_name,
    columns_to_append = columns_to_append,
    feature_json_join_columns = feature_json_join_columns,
    relationship = relationship_factory[relationship_name]

)) %}

{% endmacro %}
