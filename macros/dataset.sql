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

{# Create a derived dataset using self-joins from an Activity Stream model.

params:

    activity_stream_ref: ref()
        The dbt ref() that points to the activty stream table. Use the project
        variables in ./dataclasses/columns.sql to set the columns of the activity
        stream.

    primary_activity: activity (class)
        The primary activity of the derived dataset.

    appended_activities: List[ activity (class) ]
        The list of appended activities to self-join to the primary activity.
#}

{% set columns = dbt_activity_schema.columns() %}
{% set stream = dbt_activity_schema.generate_stream_alias %}
{% set alias = dbt_activity_schema.generate_appended_column_alias %}
{% set render_join = dbt_activity_schema.render_additional_join_condition %}
{% set render_agg = dbt_activity_schema.render_aggregation %}


with

join_appended_activities as (
    select

        -- Primary Activity Columns
        {% for col in primary_activity.columns %}
        {{ stream() }}.{{- col }},
        {% endfor %}

        -- Appended Activties Columns
        {% for activity in appended_activities %}{% set i = loop.index %}{% set last_outer_loop = loop.last %}
            {% for col in activity.columns %}

        {{ stream(i) }}.{{ col }} as {{ alias(activity, col) }}{% if not (last_outer_loop and loop.last) %},{% endif %}

            {% endfor %}
        {% endfor %}

    from {{ activity_stream_ref }} as {{ stream() }}

    -- Join Appended Activities Loop
    {% for activity in appended_activities %}{% set i = loop.index %}

    left join {{ activity_stream_ref }} as {{ stream(i) }}
        on (
            -- Join on Customer UUID Column
            {{ stream(i) }}.{{ columns.customer }} = {{ stream() }}.{{ columns.customer }}

            -- Join the Correct Activity
            and {{ stream(i) }}.{{- columns.activity }} = {{ dbt.string_literal(activity.name) }}

            -- Relationship Specific Join Conditions
            and (
            {# nth_ever_join_clause relies on instantiated nth_occurance arg, in
            addition to the i passed to the join #}
            {% if activity.relationship.name == "nth_ever" %}
            {{ activity.relationship.join_clause(activity.relationship.nth_occurance, i) }}
            {% else %}
            {{ activity.relationship.join_clause(i) }}
            {% endif %}
            )
            -- Additional Join Condition
            and ( {{ render_join(activity.additional_join_condition, i) }} )
        )

    {% endfor %}

    -- Where Clause for the Primary Activity, Determined by the `occurance`
    where {{ stream() }}.{{ columns.activity }} = {{ dbt.string_literal(primary_activity.name) }}
        and {{ primary_activity.relationship.where_clause }}
),

aggregate_appended_activities as (
    select
        {% for col in primary_activity.columns %}
        {{- col }},
        {% endfor %}

        {% for activity in appended_activities %}{% set i = loop.index %}{% set last_outer_loop = loop.last %}
            {% for col in activity.columns %}

        {{ render_agg(col, activity) }}

        {% if not (last_outer_loop and loop.last) %},{% endif %}

            {% endfor %}
        {% endfor %}

    from join_appended_activities
    group by
        {% for col in primary_activity.columns %}
        {{- col }}{% if not loop.last %},{% endif %}
        {% endfor %}
)

select * from aggregate_appended_activities

{% endmacro %}
