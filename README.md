# dbt-activity-schema <!-- omit in toc -->

A [dbt-Core](https://docs.getdbt.com/docs/introduction) [package](https://docs.getdbt.com/docs/build/packages#what-is-a-package) which contains macros to self-join an _activity stream_: the primary table in the [Activity Schema](https://github.com/ActivitySchema/ActivitySchema/blob/main/2.0.md) data modelling framework.

## Table of Contents <!-- omit in toc -->
- [Install](#install)
- [Usage](#usage)
- [Contributions](#contributions)

## Install
Include in `packages.yml`:

```yaml
packages:
  - git: "https://github.com/tnightengale/dbt-activity-schema"
    revision: 0.0.1
```
For latest release, see
https://github.com/tnightengale/dbt-activity-schema/releases.

## Usage
Use the `dataset.sql` macro with the appropriate params to generate a self-joined dataset from the activity stream model in your project, eg:
```SQL
{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.primary_activity("All","bought something"),
        [
            dbt_activity_schema.append_activity("first_before", "visited page")
        ]
    )
}}

```
See the signature in the macro for more details on each parameter.

## Contributions
Contributions and feedback are welcome. Please create an issue if you'd like to contribute.
