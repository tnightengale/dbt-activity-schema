{% macro generate_stream_alias(i=none) %}
	{{ return(adapter.dispatch("generate_stream_alias", "dbt_activity_schema")(i))}}
{% endmacro %}


{%- macro default__generate_stream_alias(i) -%}

{# Generate the alias for the stream and it's appended activities.

params:

    i: int
        The cardinality of the appended activity, and thus the self join of the
        Activity Schema. Used to rejoin the Activity Schema multiple times, for
        multiple appended activities, with each being given a unique alias.

#}

{%- if i -%}
stream_{{- i }}
{%- else -%}
stream
{%- endif -%}

{%- endmacro -%}
