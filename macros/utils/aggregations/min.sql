{% macro min() %}
min({{ caller() }})
{% endmacro %}
