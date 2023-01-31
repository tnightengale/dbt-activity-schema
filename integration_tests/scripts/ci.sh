#!/bin/sh

dbt deps
dbt build -x
