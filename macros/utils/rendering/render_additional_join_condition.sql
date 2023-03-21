
{%- macro render_additional_join_condition(clause, i) -%}
	{{ return(adapter.dispatch("render_additional_join_condition", "dbt_activity_schema")(clause, i)) }}
{%- endmacro -%}


{%- macro default__render_additional_join_condition(clause, i) -%}

{# Replace the "{primary}" and "{appended}" placeholders with appropriate
cardinality.

params:

    clause: str
        The boolean join condition, with optional "{primary}" and
        "{appended}" placeholders.

    i: int
        The cardinality of the appended activity, and thus the self join of the
        Activity Schema. Used to rejoin the Activity Schema multiple times, for
        multiple appended activities, with each being given a unique alias.
#}

{%- do return(
    clause.format(
        primary=dbt_activity_schema.stream(),
        appended=dbt_activity_schema.appended()
    )
) -%}

{%- endmacro -%}
