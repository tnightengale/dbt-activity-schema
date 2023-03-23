{% macro max() %}

{% do return(dbt_activity_schema._min_or_max("max", caller())) %}

{% endmacro %}
