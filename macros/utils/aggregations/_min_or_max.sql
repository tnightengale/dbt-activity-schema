{% macro _min_or_max(min_or_max, qualified_col) %}

{% set aggregation = "min_by" if min_or_max == "min" else "max_by" %}
{% set qualified_ts_col = "{}.{}".format(
    dbt_activity_schema.appended(), dbt_activity_schema.columns().ts
) %}

{# Apply min or max by to the selected column #}
{% set aggregated_col %}
    {{ aggregation }}({{ qualified_col }}, {{ qualified_ts_col }})
{% endset %}

{# Return output. #}
{% set output %}
{{ aggregated_col }}
{% endset %}

{% do return(output) %}

{% endmacro %}
