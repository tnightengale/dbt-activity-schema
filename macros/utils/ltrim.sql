{%- macro ltrim(col, characters=none) -%}
	{{ return(adapter.dispatch("ltrim", "dbt_activity_schema")(col, characters)) }}
{%- endmacro -%}


{%- macro default__ltrim(col, characters) -%}

{% if characters %}
ltrim({{ col }}, {{ characters }})
{% else %}
ltrim({{ col }})
{% endif %}

{% endmacro %}
