{% macro parse_column(table_alias, column) %}

{% set columns = dbt_activity_schema.columns() %}
{%- if column not in columns.values() -%}
    {%- set parsed_column = dbt_activity_schema.json_unpack_key(table_alias ~ '.' ~ columns.feature_json, column) -%}
{%- else -%}
    {%- set parsed_column = table_alias ~ '.' ~ column -%}
{%- endif -%}

{% do return(parsed_column) %}
{% endmacro %}
