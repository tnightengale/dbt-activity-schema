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

{% set columns = dbt_activity_schema.columns() %}
{% set stream = dbt_activity_schema.globals().stream %}
{% set alias = dbt_activity_schema.alias %}

with 

join_appended_activities as (
    select
        stream.{{- columns.activity_id }},
        stream.{{- columns.customer }},
        stream.{{- columns.ts }},
        stream.{{- columns.activity }},
        stream.{{- columns.anonymous_customer_id }},
        stream.{{- columns.feature_json }},
        stream.{{- columns.revenue_impact }},
        stream.{{- columns.link }},
        stream.{{- columns.activity_occurrence }},
        stream.{{- columns.activity_repeated_at }},

        {% for activity in appended_activities %}{% set i = loop.index %}

            stream_{{ i }}.{{ columns.ts }} as {{ alias(activity, columns.ts)}},
            stream_{{ i }}.{{ columns.feature_json }} as {{ alias(activity, columns.feature_json)}}
            
        {%- if not loop.last -%},{% endif %}{% endfor %}

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
        {{ columns.activity_id }},
        {{ columns.customer }},
        {{ columns.ts }},
        {{ columns.activity }},
        {{ columns.anonymous_customer_id }},
        {{ columns.feature_json }},
        {{ columns.revenue_impact }},
        {{ columns.link }},
        {{ columns.activity_occurrence }},
        {{ columns.activity_repeated_at }},

        {% for activity in appended_activities %}{% set i = loop.index %}

        min(
            {{- alias(activity, columns.feature_json) -}}
        ) as {{- alias(activity, columns.feature_json) -}},

        {{ activity.relationship.aggregation_func }}(
            {{- alias(activity, columns.ts) -}}
        ) as {{ alias(activity, columns.ts) }}

        {%- if not loop.last -%},{% endif %}{% endfor %}

    from join_appended_activities
    group by
        {{ columns.activity_id }},
        {{ columns.customer }},
        {{ columns.ts }},
        {{ columns.activity }},
        {{ columns.anonymous_customer_id }},
        {{ columns.feature_json }},
        {{ columns.revenue_impact }},
        {{ columns.link }},
        {{ columns.activity_occurrence }},
        {{ columns.activity_repeated_at }}
)

select * from aggregate_appended_activities

{% endmacro %}
