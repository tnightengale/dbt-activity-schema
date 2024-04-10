{% macro dataset(
    activity_stream,
    primary_activity,
    appended_activities=[]
) %} {{ return(adapter.dispatch("dataset", "dbt_activity_schema")(
    activity_stream,
    primary_activity,
    appended_activities
)) }} {% endmacro %}

{% macro default__dataset(
    activity_stream,
    primary_activity,
    appended_activities
) %}

{# Create a derived dataset using self-joins from an Activity Stream model.

params:

    activity_stream: ref() | str
        The dbt `ref()` or a CTE name that contains the required columns.

    primary_activity: activity (class)
        The primary activity of the derived dataset.

    appended_activities: List[ activity (class) ]
        The list of appended activities to self-join to the primary activity.
#}

{% set columns = dbt_activity_schema.columns() %}
{% set primary = dbt_activity_schema.primary %}
{% set alias_cte = dbt_activity_schema.alias_cte %}
{% set alias_column = dbt_activity_schema.alias_column %}
{% set alias_appended_activity = dbt_activity_schema.alias_appended_activity %}
{% set render_join = dbt_activity_schema.render_additional_join_condition %}
{% set render_agg = dbt_activity_schema.render_aggregation %}

with

dataset as (
    select
        {% for col in primary_activity.included_columns + primary_activity.required_columns %}
        {{ dbt_activity_schema.parse_column(primary(), col) }} as {{ col }},
        {% endfor %}
        {% for activity in appended_activities %}{% set i = loop.index %}{% set last_outer_loop = loop.last %}
            {% for col in activity.included_columns %}
                {% call activity.relationship.aggregation_func() %}
                {{ dbt_activity_schema.parse_column(alias_cte(activity, i), col) }}
                {% endcall %} as {{ dbt_activity_schema.alias_appended_activity(activity, col) }}
                {% if not (loop.last and last_outer_loop) %},{% endif %}
            {% endfor %}
        {% endfor %}
    from (
        select *
        from {{ activity_stream }}
        where
            {{ columns.activity }} = {{ dbt.string_literal(primary_activity.name) }}
            and {{ primary_activity.relationship.where_clause }}
    ) as {{ primary() }}
    {% for activity in appended_activities %}{% set i = loop.index %}
    {% set appended = alias_cte(activity, i) %}
    left join (
        select *
        from {{ activity_stream }}
        where {{ columns.activity }} = {{ dbt.string_literal(activity.name) }}
    ) as {{ appended }}
        on (
            -- Join on Customer UUID Column
            {{ appended }}.{{ columns.customer }} = {{ primary() }}.{{ columns.customer }}

            -- Relationship Specific Join Conditions
            and (
            {% if activity.relationship.name == "nth_ever" %}
            {# nth_ever_join_clause relies on instantiated nth_occurance arg, in
            addition to the i passed to the join #}
            {{ activity.relationship.join_clause(relationship.nth_occurance, appended) }}
            {% elif activity.relationship.name in ("first_ever", "last_ever") %}
            {# relies on appended subquery/CTE name #}
            {{ activity.relationship.join_clause(appended) }}
            {% elif activity.relationship.name in ("all_ever", "aggregate_all_ever") %}
            {# doesn't rely on anything #}
            {{ activity.relationship.join_clause() }}
            {% else %}
            {# These need primary and appended subquery/CTE names, the zero is unused #}
            {{ activity.relationship.join_clause(0, primary(), appended) }}
            {% endif %}
            )
            {# Additional Join Condition relies on primary and appended subquery/CTE names #}
            {% if activity.additional_join_condition is string %}
            and ( {{ activity.additional_join_condition(primary=primary(), appended=appended) }} )
            {% else %}
            and ( {{ activity.additional_join_condition(primary(), appended) }} )
            {% endif %}
        )
    {% endfor %}
    group by
        {% for col in primary_activity.included_columns %}
        {{ primary() }}.{{ col }}{%- if not loop.last -%},{%- endif %}
        {% endfor %}
)

select * from dataset

{% endmacro %}
