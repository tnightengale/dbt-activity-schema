{% macro relationship(name) %}
	{{ return(adapter.dispatch("relationship", "dbt_activity_schema")(name))}}
{% endmacro %}


{% macro default__relationship(name) %}

{# The relationship of the appended_activty.

params:

    name: str
        The string identifier of the defined activity relationship, one of;
            1. "first_ever"
            2. "last_ever"
            3. "first_before"
            4. "last_before"
            5. "first_after"
            6. "last_after"
            TODO: 7. "aggregate_after"
            TODO: 8. "aggregate_all_ever
            TODO: ...
#}

{% set relationship_factory = dict(
    first_before = dbt_activity_schema.first_before(),
    first_ever = dbt_activity_schema.first_ever(),
    last_before = dbt_activity_schema.last_before(),
    last_ever = dbt_activity_schema.last_ever(),
    first_after = dbt_activity_schema.first_after(),
    last_after = dbt_activity_schema.last_after()
) %}

{% do return(relationship_factory[name]) %}

{% endmacro %}
