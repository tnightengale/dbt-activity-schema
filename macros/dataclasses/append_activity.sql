{% macro append_activity(relationship_name, activity_name) %}
	{{ return(adapter.dispatch("append_activity", "dbt_activity_schema")(relationship_name, activity_name))}}
{% endmacro %}

{% macro default__append_activity(relationship_name, activity_name) %}

{# An activity to append to the `primary_activity`.

params:

    relationship_name: str (enum)
        The string identifier of the defined activity relationship, one of;
            1. "first_ever"
            2. "last_ever"
            3. "first_before"
            4. "last_before"
            5. "first_after"
            6. "last_after"
            7. "aggregate_after"
            8. "aggregate_all_ever"
            
    activity_name: str
        The string identifier of the activity in the stream to append (join).
#}

{% set relationship_factory = dict(
    first_before = dbt_activity_schema.first_before(),
    first_ever = dbt_activity_schema.first_ever(),
    last_before = dbt_activity_schema.last_before(),
    last_ever = dbt_activity_schema.last_ever(),
    first_after = dbt_activity_schema.first_after(),
    last_after = dbt_activity_schema.last_after()
) %}

{% do return(namespace(
    name = activity_name,
    relationship = relationship_factory[relationship_name]

)) %}

{% endmacro %}
