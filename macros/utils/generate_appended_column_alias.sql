{% macro generate_appended_column_alias(activity, column_name) %}
	{{ return(adapter.dispatch("generate_appended_column_alias", "dbt_activity_schema")(activity, column_name))}}
{% endmacro %}


{% macro default__generate_appended_column_alias(activity, column_name) %}

{# Generate the name of appended columns in `dataset.sql`.

params:

    activity: appended_activity (activites)
        The appended activity object, containing the string attributes to be concatenated in the
        column alias prefix.

    column_name: str
        The name of the column that will be concatenated in the column alias suffix.
#}

{% set concatenated_activity_alias %}
{{ activity.relationship.name -}}_{{- activity.name | replace(" ", "_") -}}_{{- column_name -}}
{% endset %}

{% do return(concatenated_activity_alias) %}

{% endmacro %}
