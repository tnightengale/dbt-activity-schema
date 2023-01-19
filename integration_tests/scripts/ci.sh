#!/bin/sh

dbt seed --full-refresh
dbt run
dbt test
