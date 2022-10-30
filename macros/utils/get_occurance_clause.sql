{% macro get_occurance_clause(occurance) %}
	{{ return(adapter.dispatch("get_occurance_clause", "dbt_activity_schema")(occurance))}}
{% endmacro %}

{% macro default__get_occurance_clause(occurance) %}
    {#
        params:
        
            occurance: str | int
            One of 'All', 'Last', or an Integer representing the Nth activty to fetch.
    #}
    {% set occurance = occurance | int %}

    {% set occurance_clause %}
    {%- if occurance == "All" -%}
        (true)
    {%- elif occurance == "Last" -%}
        ({{ dbt_activity_schema.columns().activity_repeated_at }} is null)
    {%- else -%}
        {# Ensure an integer was passed #}
        {%- if occurance is odd or occurance is even -%}
        ({{ dbt_activity_schema.columns().activity_occurrence }} == {{ occurance }})
        {% else %}
        {{ exceptions.raise_compiler_error("Invalid `occurance`. Expect 'All', 'Last' or INT. Got: " ~ occurance) }}
        {% endif %}
    {% endif %}
    {% endset %}

    {% do return(occurance_clause) %}

{% endmacro %}
