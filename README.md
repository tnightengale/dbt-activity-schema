# dbt-activity-schema <!-- omit in toc -->

A [dbt-Core](https://docs.getdbt.com/docs/introduction)
[package](https://docs.getdbt.com/docs/build/packages#what-is-a-package) which
contains macros to create derived Datasets by self-joining an [Activity
Stream](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#activity-stream),
the primary table in the [Activity
Schema](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md) data
modelling framework.

## Table of Contents <!-- omit in toc -->
- [Install](#install)
- [Usage](#usage)
  - [Create a Dataset](#create-a-dataset)
  - [Configure Columns](#configure-columns)
    - [Required Columns](#required-columns)
    - [Mapping Column Names](#mapping-column-names)
    - [Included Dataset Columns](#included-dataset-columns)
    - [Configure Appended Activity Column Names](#configure-appended-activity-column-names)
- [Macros](#macros)
  - [dataset (source)](#dataset-source)
  - [activity (source)](#activity-source)
- [Relationships](#relationships)
- [Warehouses](#warehouses)
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
Use the [dataset macro](###dataset-source) with the appropriate arguments to
derive a Dataset by self-joining the Activity Stream model in your project. The
[dataset macro](###dataset) will compile based on the provided [activity
macros](###activity-source) and the [relationship macros](##relationships). It
can then be nested in a CTE in a dbt-Core model. Eg:
```c
// my_first_dataset.sql

with

dataset_cte as (
    {{ dbt_activity_schema.dataset(
        activity_stream_ref = ref("example__activity_stream"),

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
> model. It derives Dataset models on top of an existing Activity Stream model.

### Configure Columns
This package conforms to the [Activity Schema V2
Specification](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md#entity-table)
and, by default, it expects the columns in that spec to exist in the Activity Stream model.

#### Required Columns
In order for critical joins in the [dataset macro](###dataset) to work as
expected, the following columns must exist:
  - **`activity`**: A string or ID that identifies the action or fact
    attributable to the `customer`.
  - **`customer`**: The UUID of the entity or customer. Must be used across
    activities.
  - **`ts`**: The timestamp at which the activity occurred.
  - **`activity_repeated_at`**: The timestamp of the next activity, per
    customer. Create using a lead window function, partitioned by activity and
    customer.
  - **`activity_occurrence`**: The running count of the actvity per customer.
    Create using a rank window function, partitioned by activity and customer.

#### Mapping Column Names
If the required columns exist conceptually under different names, they can be
aliased using the nested `activity_schema_v2_column_mappings` project var. Eg:

```yml
# dbt_project.yml

...

vars:
  dbt_activity_schema:
    activity_schema_v2_column_mappings:
      # Activity Stream with required column names that
      # differ from the V2 spec, mapped from their spec name.
      customer: entity_uuid
      ts: activity_occurred_at

...
```

#### Included Dataset Columns
The set of columns that are included in the compiled SQL of the [dataset
macro](###dataset-source) can be configured using the nested
`default_dataset_columns` project var. Eg:
```yml
# dbt_project.yml

...

vars:
  dbt_activity_schema:
    # List columns from the Activity Schema to include in the Dataset
    default_dataset_columns:
      - activity_id
      - entity_uuid
      - activity_occurred_at
      - revenue_impact

...
```

These defaults can be overriden using the `override_columns` argument in the
[activity macro](###activity-source).

#### Configure Appended Activity Column Names
The naming convention of the columns, in the activities passed to the
`appended_activities` argument can be configured by overriding the
[generate_appended_column_alias](./macros/utils/generate_appended_column_alias.sql)
macro. See the dbt docs on [overriding package
macros](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch#overriding-package-macros)
for more details.

## Macros
---
### dataset ([source](macros/dataset.sql))
Create a derived dataset using self-joins from an Activity Stream model.

**params:**
- **`activity_stream_ref (required)`** : [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)

  The dbt `ref()` that points to the activty stream model.

- **`primary_activity (required)`** : [activity](###activity)

  The primary activity of the derived dataset.

- **`appended_activities (optional)`** : List [ [activity](###activity) ]

  The list of appended activities to self-join to the primary activity.

### activity ([source](macros/activity.sql))
Represents either the primary activity or one of the appended activities in a
dataset.

**params:**
- **`relationship (required)`** : [relationship](##relationships)

  The relationship that defines how the activity is filtered or joined,
  depending on if it is provided to the `primary_activity` or
  `appended_activities` argument in the dataset macro.

- **`activity_name (required)`** : str

  The string identifier of the activity in the Activity Stream. Should match the
  value in the `activity`  column.

- **`override_columns (optional)`** : List [ str ]

  List of columns to include for the activity. Setting this Overrides the defaults configured
  by the `default_dataset_columns` project var.

- **`additional_join_condition (optional)`** : str

  A valid SQL boolean to condition the join of the appended activity. Can
  optionally contain the python f-string placeholders `{primary}` and
  `{appended}` in the string. These placeholders will be compiled by the
  [dataset macro](./macros/dataset.sql) with the correct SQL aliases for the
  joins between the primary activity and the appended activity.

  Eg:
  ```python
  "json_extract({primary}.feature_json, 'dim1') =
      json_extract({appended}.feature_json, 'dim1')"
  ```
  The `{primary}` and `{appended}` placeholders compile according to
  the cardinality of the activity in the `appended_activities` list
  argument to `dataset.sql`.

  Compiled:
  ```python
  "json_extract(stream.feature_json, 'dim1') =
      json_extract(stream_3.feature_json, 'dim1')"
  ```
  Given that the appended activity was 3rd in the `appended_activities` list
  argument.

## Relationships
See the [relationships/](macros/relationships/) path for the most up to date
relationships and their documentation.

## Warehouses
To the best of the author's knowledge this jinja-macros in this package are
supported for all dbt adapters.

## Contributions
Contributions and feedback are welcome. Please create an issue if you'd like to
contribute.
