{% macro primary_activity(occurance, activity_name) %}
	{{ return(adapter.dispatch("primary_activity", "dbt_activity_schema")(occurance, activity_name))}}
{% endmacro %}

{% macro default__primary_activity(occurance, activity_name) %}

{# params

occurance: str (enum) | int
    One of 'All', 'Last', or an integer representing the Nth activty to fetch.
        
activity_name: str
    The string identifier of the activity in the stream to append (join).
#}

{% set where_clause %}

{%- if occurance == "All" -%}
    (true)
{%- elif occurance == "Last" -%}
    ({{ dbt_activity_schema.columns().activity_repeated_at }} is null)
{%- elif occurance is odd or occurance is even -%} {# Check if an integer was passed #}
    (stream.{{ dbt_activity_schema.columns().activity_occurrence }} = {{ occurance }})
{% else %}
    {{ exceptions.raise_compiler_error("Invalid `occurance`. Expect 'All', 'Last' or INT. Got: " ~ occurance) }}
{% endif %}

{% endset %}

{% do return(namespace(
    name = activity_name,
    where_clause = where_clause

)) %}

{% endmacro %}
