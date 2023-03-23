{% macro alias_column(column_name, i=none) %}
	{{ return(adapter.dispatch("alias_column", "dbt_activity_schema")(column_name, i))}}
{% endmacro %}


{%- macro default__alias_column(column_name, i) -%}

{# Generate the alias for the stream and it's appended activities.

params:

    column_name: str
        The name of the column that will be aliased.

    i: int
        The cardinality of the appended activity, and thus the self join of the
        Activity Schema. Used to rejoin the Activity Schema multiple times, for
        multiple appended activities, with each being given a unique alias.

#}

{% set alias %}
{{ dbt_activity_schema.appended() }}.{{ column_name }}
{% endset %}

{% do return(alias) %}

{%- endmacro -%}
