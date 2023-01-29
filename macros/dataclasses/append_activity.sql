{% macro append_activity(relationship_name, activity_name) %}
	{{ return(adapter.dispatch("append_activity", "dbt_activity_schema")(relationship_name, activity_name))}}
{% endmacro %}

{% macro default__append_activity(relationship_name, activity_name) %}

{# params

relationship_name: str (enum)
    The string identifier of the defined activity relationship, one of;
        1. "first_ever"
        2. "last_ever"
        3. "first_before"
        4. "last_before"
        5. "first_in_between"
        6. "last_in_between"
        7. "aggregate_in_between"
        8. "aggregate_all_ever"
        
activity_name: str
    The string identifier of the activity in the stream to append (join).
#}
{# last_ever = last_ever()
first_before = first_before()
last_before = last_before()
first_in_between = first_in_between()
last_in_between = last_in_between()
aggregate_in_between = aggregate_in_between()
aggregate_all_ever = aggregate_all_ever() #}

{% set relationship_factory = dict(
    first_ever = dbt_activity_schema.first_ever(),
    first_in_between = dbt_activity_schema.first_in_between()
) %}

{% do return(namespace(
    name = activity_name,
    relationship = relationship_factory[relationship_name]

)) %}

{% endmacro %}
