
{%- macro render_additional_join_condition(clause, i) -%}
	{{ return(adapter.dispatch("render_additional_join_condition", "dbt_activity_schema")(clause, i)) }}
{%- endmacro -%}


{%- macro default__render_additional_join_condition(clause, i) -%}

{# Replace the "{stream}" and "{joined}" placeholders with appropriate
cardinality.

params:

    clause: str
        The boolean join condition, with optional "{stream}" and
        "{joined}" placeholders.

    i: int
        The cardinality of the appended activity, and thus the self join of the
        Activity Schema. Used to rejoin the Activity Schema multiple times, for
        multiple appended activities, with each being given a unique alias.
#}

{%- do return(
    clause.format(
        stream=dbt_activity_schema.generate_stream_alias(),
        joined=dbt_activity_schema.generate_stream_alias(i)
    )
) -%}

{%- endmacro -%}
