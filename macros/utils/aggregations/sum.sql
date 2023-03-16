{% macro sum() %}
sum({{ caller() }})
{% endmacro %}
