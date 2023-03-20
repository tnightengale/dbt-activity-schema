{% macro count() %}
count({{ caller() }})
{% endmacro %}
