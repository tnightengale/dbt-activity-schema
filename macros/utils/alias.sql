{% macro alias(activity, column_name) %}

{# params

activity: append_activity (class)
    The activity object, containing the string attributes to be concatenated in the
    column alias prefix.

column_name: str
    The name of the column that will be concatenated in the column alias suffix.
#}

{% set concatenated_activity_alias %}
{{ activity.relationship.name -}}_{{- activity.name | replace(" ", "_") -}}_{{- column_name -}} 
{% endset %}

{% do return(concatenated_activity_alias) %}

{% endmacro %}
