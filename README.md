# dbt-activity-schema <!-- omit in toc -->

A [dbt](https://docs.getdbt.com/docs/introduction)
[package](https://docs.getdbt.com/docs/build/packages#what-is-a-package) to
query the [Activity
Schema](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md) data
modelling framework, based on the
[relationships](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#relationships).

## Table of Contents <!-- omit in toc -->
- [Overview](#overview)
- [Install](#install)
- [Usage](#usage)
  - [Create a Dataset](#create-a-dataset)
  - [Required Columns](#required-columns)
- [Vars](#vars)
  - [Column Mappings (optional)](#column-mappings-optional)
  - [Included Columns (optional)](#included-columns-optional)
- [Macros](#macros)
  - [Dataset (source)](#dataset-source)
  - [Activity (source)](#activity-source)
- [Relationships](#relationships)
  - [All Ever (source) (*Custom*)](#all-ever-source-custom)
  - [Nth Ever (source) (*Custom*)](#nth-ever-source-custom)
  - [First Ever (source)](#first-ever-source)
  - [Last Ever (source)](#last-ever-source)
  - [First Before (source)](#first-before-source)
  - [Last Before (source)](#last-before-source)
  - [First After (source)](#first-after-source)
  - [Last After (source)](#last-after-source)
  - [First In Between (source)](#first-in-between-source)
  - [Last In Between (source)](#last-in-between-source)
  - [Aggregate All Ever (source) (*Custom*)](#aggregate-all-ever-source-custom)
  - [Aggregate After (source) (*Custom*)](#aggregate-after-source-custom)
  - [Aggregate Before (source)](#aggregate-before-source)
  - [Aggregate In Between (source)](#aggregate-in-between-source)
- [Aggregations](#aggregations)
  - [Custom Aggregations](#custom-aggregations)
- [Warehouses](#warehouses)
- [Contributions](#contributions)

## Overview
This [dbt](https://docs.getdbt.com/docs/introduction) package includes
[macros](https://docs.getdbt.com/docs/build/jinja-macros) to simplify the
querying of an [Activity
Stream](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#activity-stream),
the primary table in the Activity Schema data modelling framework.

> **Note:** Use this package to query an Activity Stream model that is _already
> defined_ in a dbt project. **It is not intended to _create_ an Activity Stream
> model in a dbt project.**

It relies on the [Activity Schema V2
Specification](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md).

It leverages and extends the
[relationships](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#relationships)
defined in that spec to self-join activities in the Activity Stream.

## Install
Include in `packages.yml`:

```yaml
packages:
  - package: tnightengale/dbt_activity_schema
    version: 0.4.1
```
For latest release, see
https://github.com/tnightengale/dbt-activity-schema/releases.

## Usage

### Create a Dataset
Use the [dataset macro](#dataset-source) to self-join an Activity Stream using
[relationships](#relationships).

The [dataset macro](#dataset-source) will compile based on the provided
[activity macros](#activity-source) and the [relationship
macros](#relationships). It can then be nested in a CTE in a dbt-Core model. Eg:
```sql
// my_first_dataset.sql

with

dataset_cte as (
    {{ dbt_activity_schema.dataset(
        activity_stream = ref("example__activity_stream"),

        primary_activity = dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(), "bought something"),

        appended_activities = [
          dbt_activity_schema.activity(
              dbt_activity_schema.first_before(), "visited page"),
           dbt_activity_schema.activity(
              dbt_activity_schema.first_after(), "bought item"),
        ]
    ) }}
)

select * from dataset_cte

```
> Note: This package does not contain macros to create the Activity Stream
> model. It generates the SQL to self-join an existing Activity Stream model.

### Required Columns
This package conforms to the [Activity Schema V2
Specification](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#entity-table)
and requires the following columns to function:
  - **`activity`**: A string or ID that identifies the action or fact
    attributable to the `customer`.
  - **`customer`**: The UUID of the entity or customer. Must be used across
    activities.
  - **`ts`**: The timestamp at which the activity occurred.
  - **`activity_repeated_at`**: The timestamp of the next activity, per
    customer. Create using a lead window function, partitioned by activity and
    customer.
  - **`activity_occurrence`**: The running count of the activity per customer.
    Create using a rank window function, partitioned by activity and customer.

## Vars
This package can be configured with the following project variables. All project
vars can be scoped globally or to the `dbt_activity_schema` package.

### Column Mappings (optional)
The `column_mappings` project variable can be used to alias columns in Activity
Stream. If the [required columns](#required-columns) exist conceptually under
different names, they can be mapped to their names in the [V2
Specification](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#entity-table).
Eg:

```yml
# dbt_project.yml
...

vars:
  dbt_activity_schema:
    column_mappings:
      # Activity Stream with required column names that
      # differ from the V2 spec, mapped from their spec name.
      customer: entity_uuid
      ts: activity_occurred_at

...
```

### Included Columns (optional)
The `included_columns` project variable can be set to indicate the default
columns to be included in each [activity](#activity-source) passed to
[dataset](#dataset-source). Eg:
```yml
# dbt_project.yml
...

vars:
  dbt_activity_schema:
    # List columns from the Activity Schema to include in the Dataset
    included_columns:
      - activity_id
      - entity_uuid
      - activity_occurred_at
      - revenue_impact

...
```

If it is not set, all the columns from the [V2
Specification](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#entity-table)
will be included, based on the [columns macro](./macros/utils/columns.sql).

These defaults can be overridden on a per-activity basis by passing a list of
column names to the `included_columns` argument in the [activity
macro](#activity-source).

## Macros

### Dataset ([source](macros/dataset.sql))
Generate the SQL for self-joining the Activity Stream.

**args:**
- **`activity_stream (required)`** :
  [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) | str

  The dbt `ref()` or a CTE name that contains the [required
  columns](#required-columns).

- **`primary_activity (required)`** : [activity](#activity-source)

  The primary activity of the derived dataset.

- **`appended_activities (optional)`** : List [ [activity](#activity-source) ]

  The list of appended activities to self-join to the primary activity. All
  appended activities and their relationship are with respect to the primary
  activity.

### Activity ([source](macros/activity.sql))
Represents either the primary activity or one of the appended activities in a
dataset.

**args:**
- **`relationship (required)`** : [relationship](#relationships)

  The relationship that defines how the activity is filtered or joined,
  depending on if it is provided to the `primary_activity` or
  `appended_activities` argument in the dataset macro.

- **`activity_name (required)`** : str

  The string identifier of the activity in the Activity Stream. Should match the
  value in the `activity`  column.

- **`included_columns (optional)`** : List [ str ]

  List of columns to include for the activity. Setting this overrides the
  defaults configured by the `default_dataset_columns` project var. If a column
  specified is not identified as any of the columns (or their project-specific
  aliases) from the Activity Schema spec, the column is assumed to be contained in
  the corresponding activity's `feature_json` and will be extracted.

- **`additional_join_condition (optional)`** : str

  A valid sql boolean expression that is added to the join condition of the
  appended activity. The expression is an `and` with the condition created by
  the [relationship](#relationships).

  The expression can optionally contain either or both of the `{{ primary() }}`
  and `{{ appended() }}` macros, which are used to alias the primary and
  appended activities respectively. If using these aliases in the expression, it
  must be first assigned to a set block. Eg:

  ```sql
  // my_second_dataset.sql

  {% set join_condition %}
  json_extract({{ dbt_activity_schema.primary() }}.feature_json, 'type')
  = json_extract({{ dbt_activity_schema.appended() }}.feature_json, 'type')
  {% endset %}


  {{
      dbt_activity_schema.dataset(
          ref("activity_schema"),
          dbt_activity_schema.activity(
              dbt_activity_schema.all_ever(),
              "signed up"
          ),
          [
              dbt_activity_schema.activity(
                  dbt_activity_schema.first_after(),
                  "visit page",
                  additional_join_condition=join_condition
              )
          ]
      )
  }}

  ```

  The `{{ primary() }}` and `{{ appended() }}` placeholders are constants for
  the aliases used in the joins of the [dataset macro](#dataset-source). Columns
  used in the expression must be fully qualified with these aliases.

  In the above example, the value of the `type` key in the `feature_json` of the
  primary activity `feature_json` must match the value of the `type` key in the
  `feature_json` of the appended activity, in addition to the relationship join
  conditions.

## Relationships
In the Activity Schema framework,
[relationships](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#relationships)
define how an activity is joined/appended to the primary activity in a
self-joining query of the Activity Stream.

This package contains [relationship macros](./macros/relationships/) for each
relationship defined in the Activity Schema.

In the Activity Schema framework, a relationship encapsulates the logic for
self-joining an activity.

This package extends the relationships defined in the [Activity Schema V2
Specification](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md)
in two ways:
1. Some relationships can be applied to the Primary Activity *and* Appended
   Activities, whereas others can only be applied to the Appended Activities.
   - These are denoted with ✅, ❌ in the **Dataset Usage** section of each
     relationship below.
2. Relationships that are not in the spec can be defined and contributed to this
   project. These are denoted below with the (*Custom*) tag.

### All Ever ([source](./macros/relationships/all_ever.sql)) (*Custom*)
Include all occurrences of the activity in the dataset.

**Dataset Usage:**
- `primary_activity:` ✅
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **All Ever** 'called_us'. This will result in
a cross join of the activities. Therefore, this relationship, while it can be
used for an *Appended Activity* is usually applied to a *Primary Activity*.

### Nth Ever ([source](./macros/relationships/last_ever.sql)) (*Custom*)
Include the nth occurrence of the activity in the dataset.

**args:**
- **`nth_occurrence (required)`** : int

  The occurrence of the activity to include.

**Dataset Usage:**
- `primary_activity:` ✅
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **Nth Ever** 'called_us'. This will add the
customer's Nth time calling on every row, regardless of when it happened.

### First Ever ([source](./macros/relationships/first_ever.sql))
Include the first ever occurrence of the activity in the dataset.

**Dataset Usage:**
- `primary_activity:` ✅
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **First Ever** 'called_us'. This will add the
customer's first time calling to every row, regardless of whether it happened
before or after visiting the website.

### Last Ever ([source](./macros/relationships/last_ever.sql))
Include the last ever occurrence of the activity in the dataset.

**Dataset Usage:**
- `primary_activity:` ✅
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **Last Ever** 'called_us'. This will add the
customer's last time calling on every row, regardless of when it happened.

### First Before ([source](./macros/relationships/append_only/first_before.sql))
Append the first activity to occur before the primary activity.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **First Before** 'opened_email'. This will
add the the first email that the customer opened before their first visit.

### Last Before ([source](./macros/relationships/append_only/last_before.sql))
Append the last activity to occur before the primary activity.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **Last Before** 'updated_opportunity_stage'.
This will add the stage of the customer at the moment they visited the website.
(ideal for slowly changing dimensions)

### First After ([source](./macros/relationships/append_only/first_after.sql))
Append the first activity to occur after the primary activity.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For the **First Ever** 'visited_website' append **First After** 'signed_up'. For
each customer add whether or not they converted any time after their first visit
to the site.

> **Note:** Be cautious when using this with **All Ever** for the primary
> activity. It will result in adding the same **First After** activity to
> multiple primary activity records, if the appended activity occurred after
> multiple primary activities. Consider using **First In Between** instead.

### Last After ([source](./macros/relationships/append_only/last_after.sql))
Append the last activity to occur after the primary activity.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For the **First Ever** 'visited_website' append **Last After** 'returned_item.
The most recent time a customer returned an item after their first visit.

> **Note:** Be cautious when using this with **All Ever** for the primary
> activity. It will result in adding the same **Last After** activity to
> multiple primary activity records, if the appended activity occurred after
> multiple primary activities. Consider using **Last In Between** instead.

### First In Between ([source](./macros/relationships/append_only/first_in_between.sql))
Append the first activity to occur after each occurrence of the primary
activity, but before the next occurrence of the primary activity.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For **All Ever** 'visited_website' append **First In Between**
'completed_order'. On every website visit, did the customer order before the
next visit. (generally used for event-based conversion)

> **Note:** The appended activity *will also be added to the row of the final
> occurrence of the primary activity*, even though it is not technically _in
> between_ another occurrence of the primary activity. The generated SQL for the
> dataset can be filtered further if desired, to remove those rows.

### Last In Between ([source](./macros/relationships/append_only/last_in_between.sql))
Append the last activity that occurred after each occurrence of the primary
activity and before the next occurrence of the primary activity.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For **All Ever** 'visited_website' append **Last In Between** 'viewed_page'. On
every website visit, what was the last page that they viewed before leaving.

> **Note:** The appended activity *will also be added to the row of the final
> occurrence of the primary activity*, even though it is not technically _in
> between_ another occurrence of the primary activity. The generated SQL for the
> dataset can be filtered further if desired, to remove those rows.

### Aggregate All Ever ([source](./macros/relationships/append_only/aggregate_all_ever.sql)) (*Custom*)
Append a count of all activities that occurred that can be linked by the
`customer` [required column](#required-columns) to a primary activity.

**args:**
- **`aggregation_func (optional)`** : [aggregation](#aggregations)

  The aggregation macro to use on the columns passed to the
  [activity](#activity-source). See [aggregations](#aggregations) for details on
  how to create a custom aggregation to pass here.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For every 'sign up' append **Aggregate All Ever** **Completed Order**. On every
verified/signed up account, get the count of total orders placed.

### Aggregate After ([source](./macros/relationships/append_only/aggregate_after.sql)) (*Custom*)
Append a count of all activities that occurred after each occurrence of the
primary activity.

**args:**
- **`aggregation_func (optional)`** : [aggregation](#aggregations)

  The aggregation macro to use on the columns passed to the
  [activity](#activity-source). See [aggregations](#aggregations) for details on
  how to create a custom aggregation to pass here.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **Aggregate After** **Completed Order**. On
every website visit, sum the revenue that was spent on completed orders after
this visit.

### Aggregate Before ([source](.macros/relationships/../../macros/relationships/append_only/aggregate_before.sql))
Append a count of all activities that occurred before each occurrence of the
primary activity.

**args:**
- **`aggregation_func (optional)`** : [aggregation](#aggregations)

  The aggregation macro to use on the columns passed to the
  [activity](#activity-source). See [aggregations](#aggregations) for details on
  how to create a custom aggregation to pass here.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **Aggregate Before** **Completed Order**. On
every website visit, sum the revenue that was spent on completed orders before
this visit.

### Aggregate In Between ([source](./macros/relationships/append_only/aggregate_in_between.sql))
Append a count of all activities that occurred after each occurrence of the
primary activity, but before the next occurrence of the primary activity.

**args:**
- **`aggregation_func (optional)`** : [aggregation](#aggregations)

  The aggregation macro to use on the columns passed to the
  [activity](#activity-source). See [aggregations](#aggregations) for details on
  how to create a custom aggregation to pass here.

**Dataset Usage:**
- `primary_activity:` ❌
- `appended_activity:` ✅

**Example Usage:**

For every 'visited_website' append **Aggregate In Between** 'viewed_page'. On
every website visit, count the number of pages before the next visit.

## Aggregations
Each of the [relationships](#relationships) relies on an aggregation function,
located [here](./macros/utils/aggregations/).

These aggregations use the
[call](https://jinja.palletsprojects.com/en/3.1.x/templates/#call) function of
Jinja Templates, to allow complex expressions to be passed into the function.

### Custom Aggregations
To create a custom aggregation, simply define a valid SQL aggregation function
in a macro and pass it to any of the aggregation relationships. Eg:
```jinja
{% macro custom_agg() %}

sum(
  case
    when {{ caller }} is not null
      then 10
    else 1
  end
)

{% endmacro %}
```

In the example above `{{ caller() }}` will be replaced with each of the columns
passed to the [activity](#activity-source).

## Warehouses
To the best of the author's knowledge, this package is compatible with all dbt
adapters.

## Contributions
Contributions and feedback are welcome. Please create an issue if you'd like to
contribute.
