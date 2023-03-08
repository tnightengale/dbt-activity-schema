# dbt-activity-schema <!-- omit in toc -->

A [dbt-Core](https://docs.getdbt.com/docs/introduction)
[package](https://docs.getdbt.com/docs/build/packages#what-is-a-package) which
contains macros to self-join an _activity stream_: the primary table in the
[Activity
Schema](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md) data
modelling framework.

## Table of Contents <!-- omit in toc -->
- [Install](#install)
- [Usage](#usage)
  - [Create a Dataset](#create-a-dataset)
  - [Configure Columns](#configure-columns)
  - [Configure Appended Activity Column Names](#configure-appended-activity-column-names)
- [Macros](#macros)
  - [dataset (source)](#dataset-source)
  - [primary\_activity (source)](#primary_activity-source)
  - [appended\_activity (source)](#appended_activity-source)
  - [relationship (source)](#relationship-source)
  - [occurrance (source)](#occurrance-source)
- [Relationships](#relationships)
- [Contributions](#contributions)

## Install
Include in `packages.yml`:

```yaml
packages:
  - git: "https://github.com/tnightengale/dbt-activity-schema"
    revision: 0.1.0
```
For latest release, see
https://github.com/tnightengale/dbt-activity-schema/releases.

## Usage

### Create a Dataset
Use the [dataset macro](###dataset) with the appropriate arguments to generate a
dataset by self-joining the activity stream model in your project, Eg:
```SQL
{{
    dbt_activity_schema.dataset(
        activity_stream_ref = ref("example__activity_stream"),

        primary_activity = dbt_activity_schema.activity(
          dbt_activity_schema.all_ever(),"bought something"),

        appended_activities = [
          dbt_activity_schema.activity(
              dbt_activity_schema.first_before(), "visited page"),
           dbt_activity_schema.activity(
              dbt_activity_schema.first_after(), "bought item"),
        ]
    )
}}

```

### Configure Columns
This package conforms to the [Activity Schema V2 Specification]() and expects
the activity stream model to passed to the [dataset macro](###dataset) to
contain the columns in that spec. Any activity model that does not conform to
that spec, will need to alias columns using the following project vars:
```yml
# dbt_project.yml

...

vars:
  # Eg. A project where the "feature_json" column in the
  # activity stream model is called "json_metadata"
  override_columns:
    feature_json: json_metadata

...
```

By default all the columns in the [Activity Schema V2 Specification]() are
included in output of the [dataset]() for the [primary_activity]() and each [appended_activity]().

This set of columns can be configured for all invocations of [dataset]() using
the corresponding project vars:
```yml
# dbt_project.yml

...

vars:
  # Eg. Set the default primary columns names in the Activity Stream Model
  # to include in the innocations of dbt_activity_schema.dataset().
  primary_activity_columns:
    - activity_id
    - customer
    - ts
    - activity
    - anonymous_customer_id
    - json_metadata  # Note: Do not use the mapped values in the `override_columns`.
    - revenue_impact
    - link
    - activity_occurrence
    - activity_repeated_at
  appended_activity_columns:
    - json_metadata
    - ts

...
```
### Configure Appended Activity Column Names
The naming convention of the [appended_activity]() columns can be configured
by overriding the [generate_appended_column_alias]() macro. See the dbt docs on
[overriding package macros](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch#overriding-package-macros) for more details.

## Macros
-----
### dataset ([source](macros/dataset.sql))
Create a derived dataset using self-joins from an Activity Stream model.

**params:**
  - `activity_stream_ref: ref`
    - The dbt ref() that points to the activty stream table.
        Use the project variables in ./dataclasses/columns.sql to set the
        columns of the activity stream.
- `primary_activity:` [primary_activity](###primary-activity)
  - The primary activity of the derived dataset.

- `appended_activities:` List[ [appended_activity](###appended-activity) ]
  - The list of appended activities to self-join to the primary activity.


### primary_activity ([source](macros/activity/primary_activity.sql))
The primary activity of the dataset.

**params:**
- `occurance:` [occurance](###occurrance)
  - The occruance of the activity to fetch.
- `activity_name:` str
  - The string identifier of the activity in the stream to append (join).
- `override_columns:` List[str]
  - List of columns to join to the primary activity, defaults to the project var appended_activity_columns.

### appended_activity ([source](macros/activity/appended_activity.sql))
An activity to append to the `primary_activity` in the dataset.

**params:**
- `relationship:` [relationship](###relationship)
    - The relationship that defines the how the appended activity is joined to the
    primary activity.
- `activity_name:` str
    - The string identifier of the activity in the Activity Stream to join to the
    primary activity.
- `override_columns:` List[str]
    - List of columns to join to the primary activity, defaults to the project var
    `appended_activity_columns`.
- `additional_join_condition: f-string`
    - A valid sql boolean to condition the join of the appended activity. Can
      optionally contain the python f-string placeholders "{stream}" and "{joined}"
      in the string; these will be compiled with the correct aliases.

      Eg:

      "json_extract({stream}.feature_json, 'dim1')
          = "json_extract({joined}.feature_json, 'dim1')"

      The "{stream}" and "{joined}" placeholders correctly compiled depending on
      the cardinality of the joined activity in the `appended_activities` list argument
      to `dataset.sql`.

      Compiled:

      "json_extract(stream.feature_json, 'dim1')
          = "json_extract(stream_3.feature_json, 'dim1')"

      Given that the appended activity was 3rd in the `appended_activities`
      list argument.

### relationship ([source](macros/dataclasses/relationship.sql))
The relationship of the appended_activty.

**params:**
- `name: str`
    - The string identifier of the defined activity [relationship](##relationships).

### occurrance ([source](macros/dataclasses/occurance.sql))

The occurrence of the primary activity.

**params:**
- `type: str | int`
    - One of 'All', 'Last', or an integer representing the Nth activty to fetch.

## Relationships
See the [relationships/](macros/relationships/) path for the most up to date
relationships and their documentation.

## Contributions
Contributions and feedback are welcome. Please create an issue if you'd like to
contribute.
