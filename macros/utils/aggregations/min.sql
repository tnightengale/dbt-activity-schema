{% macro min() %}

{% do return(dbt_activity_schema._min_or_max("min", caller())) %}

{% endmacro %}
