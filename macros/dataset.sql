{% macro dataset(
    activity_stream_ref,
    primary_activity,
    appended_activities=[]
) %} {{ return(adapter.dispatch("dataset", "dbt_activity_schema")(
    activity_stream_ref,
    primary_activity,
    appended_activities
)) }} {% endmacro %}

{% macro default__dataset(
    activity_stream_ref,
    primary_activity,
    appended_activities
) %}

{# Create a derived dataset using self-joins from an activity stream model.

params:

    activity_stream_ref: ref()
        The dbt ref() that points to the activty stream table. Use the project
        variables in ./dataclasses/columns.sql to set the columns of the activity
        stream.

    primary_activity: primary_activity (dataclass)
        The primary activity of the derived dataset.

    appended_activities: List[append_activity (dataclass)]
        The list of appended activities to self-join to the primary activity.
#}

{% set columns = dbt_activity_schema.columns() %}
{% set stream = dbt_activity_schema.globals().stream %}
{% set alias = dbt_activity_schema.alias %}

with

join_appended_activities as (
    select
        {% for col in columns.primary_activity %}
        stream.{{- col }},
        {% endfor %}

        {% for activity in appended_activities %}{% set i = loop.index %}{% set last_outer_loop = loop.last %}
            {% for col in columns.appended_activities %}

        stream_{{ i }}.{{ col.name }} as {{ alias(activity, col.name)}}{% if not (last_outer_loop and loop.last) %},{% endif %}

            {% endfor %}
        {% endfor %}

    from {{ activity_stream_ref }} as stream

    {% for activity in appended_activities %}{% set i = loop.index %}

    left join {{ activity_stream_ref }} as stream_{{ i }}
        on (
            stream_{{ i }}.{{ columns.customer }} = stream.{{ columns.customer }}
            and stream_{{ i -}}.{{- columns.activity }} = {{ dbt.string_literal(activity.name) }}
            and {{ activity.relationship.join_clause(i) }}
        )

    {% endfor %}

    where stream.{{ columns.activity }} = '{{ primary_activity.name }}'
        and {{ primary_activity.where_clause }}
),

aggregate_appended_activities as (
    select
        {% for col in columns.primary_activity %}
        {{- col }},
        {% endfor %}

        {% for activity in appended_activities %}{% set i = loop.index %}{% set last_outer_loop = loop.last %}
            {% for col in columns.appended_activities %}

        {{ activity.relationship.aggregation_func }}(
            {{- alias(activity, col.name) -}}
        ) as {{ alias(activity, col.name)}}{% if not (last_outer_loop and loop.last) %},{% endif %}

            {% endfor %}
        {% endfor %}

    from join_appended_activities
    group by
        {% for col in columns.primary_activity %}
        {{- col }}{% if not loop.last %},{% endif %}
        {% endfor %}
)

select *  from aggregate_appended_activities

{% endmacro %}
