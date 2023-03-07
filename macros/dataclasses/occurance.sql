{% macro occurance(type) %}
	{{ return(adapter.dispatch("occurance", "dbt_activity_schema")(type))}}
{% endmacro %}


{% macro default__occurance(type) %}

{# The occurance of the primary activity.

params:

    type: str | int
        One of 'All', 'Last', or an integer representing the Nth activty to fetch.
#}

{% set where_clause %}
    {%- if type | lower == "all" -%}
        (true)
    {%- elif type | lower == "last" -%}
        ({{ dbt_activity_schema.generate_stream_alias() }}.{{ dbt_activity_schema.columns().activity_repeated_at }} is null)
    {%- elif type is odd or type is even -%} {# Check if an integer was passed #}
        ({{ dbt_activity_schema.generate_stream_alias() }}.{{ dbt_activity_schema.columns().activity_occurrence }} = {{ type }})
    {% else %}
        {{ exceptions.raise_compiler_error("Invalid `type` arg in `occurance()`. Expect 'All', 'Last' or INT. Got: " ~ type) }}
    {% endif %}
{% endset %}


{% do return(namespace(
    type = type,
    where_clause = where_clause
)) %}

{% endmacro %}
