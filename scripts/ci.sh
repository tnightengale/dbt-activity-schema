#!/bin/sh
set -ex

main () {
    cd integration_tests
    dbt deps
    dbt build -x
}

main
