{% macro activity(
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

    relationship: relationship
        The relationship that defines the how the appended activity is joined to
        the primary activity.

    activity_name: str
        The string identifier of the activity in the Activity Stream to join to
        the primary activity.

    override_columns: List[str]
        List of columns to join to the primary activity, defaults to the project
        var `appended_activity_columns`.

    additional_join_condition: str
        A valid sql boolean to condition the join of the appended activity. Can
        optionally contain the python f-string placeholders "{primary}" and
        "{appended}" in the string; these will be compiled with the correct
        aliases.

        Eg:

        "json_extract({primary}.feature_json, 'dim1')
            = "json_extract({appended}.feature_json, 'dim1')"

        The "{primary}" and "{appended}" placholders correctly compiled
        depending on the cardinatity of the joined activity in the
        `appended_activities` list argument to `dataset.sql`.

        Compiled:

        "json_extract(stream.feature_json, 'dim1')
            = "json_extract(stream_3.feature_json, 'dim1')"

        Given that the appended activity was 3rd in the `appended_activities`
        list argument.
#}

{% if override_columns %}
    {% set columns = override_columns %}
{% else %}
    {% set columns = var("dbt_activity_schema", {}).get(
        "default_dataset_columns", dbt_activity_schema.columns().values() | list
    ) %}
{% endif %}

{% set additional_join_condition = additional_join_condition if additional_join_condition else "true" %}

{% do return(namespace(
    name = activity_name,
    columns = columns,
    relationship = relationship,
    additional_join_condition = additional_join_condition
)) %}

{% endmacro %}
