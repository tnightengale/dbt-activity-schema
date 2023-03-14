{% macro max() %}
max({{ caller() }})
{% endmacro %}
