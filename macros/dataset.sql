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

select
    {{ columns.activity_id }},
    {{ columns.customer }},
    {{ columns.ts }},

    {% for activity in appended_activities %}

    {{ activity.relationship.aggregation_func }}(
        stream_{{ loop.index }}_{{ columns.ts }}
    ) as {{ activity.relationship.name -}}_{{- activity.name | replace(" ", "_") -}}_{{- columns.ts -}} 
    
        {%- if not loop.last -%},{% endif %}

    {% endfor %}

from (
    select
        stream.{{- columns.customer }},
        stream.{{- columns.activity_id }},
        stream.{{- columns.ts }},

        {% for _ in appended_activities %}

        stream_{{ loop.index }}.{{ columns.ts }} as stream_{{ loop.index }}_{{ columns.ts -}} 
        
            {%- if not loop.last -%},{% endif %}
        
        {% endfor %}

    from {{ activity_stream_ref }} as stream

    {% for activity in appended_activities %}
    {% set i = loop.index %}
    left join {{ activity_stream_ref }} as stream_{{- i }}
        on (
            stream_{{ i -}}.{{- columns.customer }} = stream.{{- columns.customer }}
            {# and {{ relationship("join", r, i) }} #}
            and {{ activity.relationship.join_clause(i) }}
        )
    {% endfor %}

    where stream.{{- columns.activity }} = '{{ primary_activity.name }}'
        and {{ primary_activity.where_clause }}

        {% for activity in appended_activities %}
        and stream_{{ loop.index }}.{{- columns.activity }} = '{{ activity.name }}'
        {% endfor %}
)
group by
    {{ columns.customer }},
    {{ columns.activity_id }},
    {{ columns.ts }}

{% endmacro %}
