{% macro alias_stream(i=none) %}
	{{ return(adapter.dispatch("alias_stream", "dbt_activity_schema")(i))}}
{% endmacro %}


{%- macro default__alias_stream(i) -%}

{# Generate the alias for the stream and it's appended activities.

params:

    i: int
        The cardinality of the appended activity, and thus the self join of the
        Activity Schema. Used to rejoin the Activity Schema multiple times, for
        multiple appended activities, with each being given a unique alias.

#}

{% set alias %}
{%- if i -%}
stream_{{- i }}
{%- else -%}
stream
{%- endif -%}
{% endset %}

{% do return(alias) %}

{%- endmacro -%}
