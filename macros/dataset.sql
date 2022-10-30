{% macro dataset(
    activity_stream_ref,
    occurance,
    primary_activity,
    additional_activities=[]
) %} {{ return(adapter.dispatch("dataset", "dbt_activity_schema")(
    activity_stream_ref,
    occurance,
    primary_activity,
    additional_activities
)) }} {% endmacro %}

{% macro default__dataset(
    activity_stream_ref,
    occurance,
    primary_activity,
    additional_activities
) %}

{% set occurance_clause = dbt_activity_schema.get_occurance_clause(occurance) %}
{% set columns = dbt_activity_schema.columns() %}


select
    {{ columns.customer }},
    {{ columns.activity_id }},
    {{ columns.ts }},

    {% for r, a in additional_activities %}
    {{ dbt_activity_schema.relationship("agg", r, loop.index) }}(stream_{{ loop.index }}.{{ columns.ts }})
        as {{ r -}}_{{- a | replace(" ", "_") -}}_{{- columns.ts }} {% if not loop.last %},{% endif %}
    {% endfor %}

from (
    select
        stream.{{- columns.customer }},
        stream.{{- columns.activity_id }},
        stream.{{- columns.ts }},

        {% for _, _ in additional_activities %}
        stream_{{ loop.index }}.{{ columns.ts }} {% if not loop.last %},{% endif %}
        {% endfor %}

    from {{ activity_stream_ref }} as stream

    {% for r, _ in additional_activities %}
    {% set i = loop.index %}
    inner join {{ activity_stream_ref }} as stream_{{- i }}
        on (
            stream_{{ i -}}.{{- columns.customer }} = stream.{{- columns.customer }}
            and {{ dbt_activity_schema.relationship("join", r, i) }}
        )
    {% endfor %}

    where stream.{{- columns.activity }} = '{{ primary_activity }}'

        {% for _, append_activity in additional_activities %}
        and stream_{{ loop.index }}.{{- columns.activity }} = '{{ append_activity }}'
        {% endfor %}
)
group by
    {{ columns.customer }},
    {{ columns.activity_id }},
    {{ columns.ts }}

{% endmacro %}
