#!/bin/bash
source "./tests/test-helper.sh"

db_name="$(_create-test-db-name)"
assert "_ls | grep $db_name" ""

_create "$db_name"
assert "_ls | grep $db_name" "$db_name"

_drop "$db_name"
assert "_ls | grep $db_name" ""

assert_end "_ls(), _create() and _drop()"
