{% macro appended_activity(
    relationship,
    activity_name,
    override_columns=[],
    additional_join_condition=[]
) %}

{{ return(adapter.dispatch("appended_activity", "dbt_activity_schema")(
    relationship,
    activity_name,
    override_columns,
    additional_join_condition
)) }}

{% endmacro %}


{% macro default__appended_activity(
    relationship,
    activity_name,
    override_columns,
    additional_join_condition
) %}

{# An activity to append to the `primary_activity` in the dataset.

params:

    relationship: relationship (/dataclasses)
        The relationship that defines the how the appended activity is joined to
        the primary activity.

    activity_name: str
        The string identifier of the activity in the Activity Stream to join to
        the primary activity.

    override_columns: List[str]
        List of columns to join to the primary activity, defaults to the project
        var `appended_activity_columns`.

    additional_join_condition: f-string
        A valid sql boolean to condition the join of the appended activity. Can
        optionally contain the python f-string placeholders "{stream}" and
        "{joined}" in the string; these will be compiled with the correct
        aliases.

        Eg:

        "json_extract({stream}.feature_json, 'dim1')
            = "json_extract({joined}.feature_json, 'dim1')"

        The "{stream}" and "{joined}" placholders correctly compiled
        depending on the cardinatity of the joined activity in the
        `appended_activities` list argument to `dataset.sql`.

        Compiled:

        "json_extract(stream.feature_json, 'dim1')
            = "json_extract(stream_3.feature_json, 'dim1')"

        Given that the appended activity was 3rd in the `appended_activities`
        list argument.
#}


{% set columns = override_columns if override_columns != [] else var("appended_activity_columns", dbt_activity_schema.columns().values() | list) %}

{% set additional_join_condition = additional_join_condition if additional_join_condition else "true" %}

{% do return(namespace(
    name = activity_name,
    columns = columns,
    relationship = relationship,
    additional_join_condition = additional_join_condition
)) %}

{% endmacro %}
