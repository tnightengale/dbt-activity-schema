{% macro primary_activity(
    occurance,
    activity_name,
    override_columns=[]
) %}

{{ return(adapter.dispatch("primary_activity", "dbt_activity_schema")(
    occurance,
    activity_name,
    override_columns
)) }}

{% endmacro %}


{% macro default__primary_activity(
    occurance,
    activity_name,
    override_columns
) %}

{# The primary activity of the dataset.

params:

    occurance: occurance (/dataclasses)
        The occruance of the activity to fetch.

    activity_name: str
        The string identifier of the activity in the stream to append (join).

    override_columns: List[str]
        List of columns to join to the primary activity, defaults to the project
        var `appended_activity_columns`.

#}

{% set columns = override_columns if override_columns != [] else var("primary_activity_columns", dbt_activity_schema.columns().values() | list) %}

{% do return(namespace(
    name = activity_name,
    where_clause = occurance.where_clause,
    columns = columns
)) %}

{% endmacro %}
