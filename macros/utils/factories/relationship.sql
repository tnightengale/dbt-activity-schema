{% macro relationship(option, name, i) %}
	{{ return(adapter.dispatch("relationship", "dbt_activity_schema")(option, name, i))}}
{% endmacro %}

{% macro default__relationship(option, name, i) %}

{% set relationship_factory = dict(
    first_ever=dbt_activity_schema.first_ever(option, i)
) %}

{% do return(relationship_factory[name]) %}

{% endmacro %}
