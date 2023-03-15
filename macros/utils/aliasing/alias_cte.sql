{%- macro alias_cte(activity, i) -%}
	{{ return(adapter.dispatch("alias_cte", "dbt_activity_schema")(activity, i))}}
{% endmacro %}


{%- macro default__alias_cte(activity, i) -%}

{# Generate the alias for the stream and it's appended activities.

params:

    activity: activity (class)
        The activity used to create the alias with a meaningful name for the
        compiled dataset.

    i: int
        The cardinality of the appended activity, and thus the self join of the
        Activity Schema. Used to rejoin the Activity Schema multiple times, for
        multiple appended activities, with each being given a unique alias.

#}

{% set alias %}
append_and_aggregate__{{ i }}__{{ activity.relationship.name }}
{% endset %}

{% do return(alias) %}

{%- endmacro -%}
