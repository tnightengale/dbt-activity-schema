{% macro activity(
    relationship,
    activity_name,
    included_columns=var("included_columns", var("dbt_activity_schema", {}).get("included_columns", dbt_activity_schema.columns().values())),
    additional_join_condition="true"
) %}

{{ return(adapter.dispatch("activity", "dbt_activity_schema")(
    relationship,
    activity_name,
    included_columns,
    additional_join_condition
)) }}

{% endmacro %}

{% macro default__activity(
    relationship,
    activity_name,
    included_columns,
    additional_join_condition
) %}

{# An activity to include in the dataset.

params:

    relationship: relationship
        The relationship that defines the how the appended activity is joined to
        the primary activity.

    activity_name: str
        The string identifier of the activity in the Activity Stream to join to
        the primary activity.

    included_columns: List[str]
        List of columns to join to the primary activity, defaults to the
        `included_columns` vars if it is set, otherwise defaults to the columns
        defined in columns.sql.

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

{% set columns = dbt_activity_schema.columns() %}

{# Required for the joins, but not necessarily included in the final result. #}
{% set required_columns = [
    columns.activity_id,
    columns.activity,
    columns.ts,
    columns.customer,
    columns.activity_occurrence,
    columns.activity_repeated_at
] %}

{% for col in included_columns %}
    {% if col in required_columns %}
        {% do required_columns.remove(col) %}
    {% endif %}
{% endfor %}

{% do return(namespace(
    name = activity_name,
    included_columns = included_columns,
    required_columns = required_columns,
    relationship = relationship,
    additional_join_condition = additional_join_condition
)) %}

{% endmacro %}
