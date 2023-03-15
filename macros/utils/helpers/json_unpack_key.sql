{% macro json_unpack_key(json_col, key) %}
	{{ return(adapter.dispatch("json_unpack_key", "dbt_activity_schema")(json_col, key))}}
{% endmacro %}

{# params

key: str
    The name of the key to unpack from the activity schema feature_json column.
#}

{% macro default__json_unpack_key(json_col, key) -%}

{% if caller %}

json_extract_path_text({{ caller }})

{% else %}

json_extract_path_text({{ json_col }}, {{dbt.string_literal(key) }})

{% endif %}

{%- endmacro %}
