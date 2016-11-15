#!/bin/bash
# shellcheck disable=1091
source "./tests/test-helper.sh"

db_name="$(_create-test-db-name)"
drop() {
  pg drop "$db_name"
}
trap drop EXIT

assert "pg | grep 'shift count'" ""

assert "pg ls | grep $db_name" ""

pg create "$db_name"
assert "pg ls | grep $db_name" "$db_name"

pg drop "$db_name"
assert "pg ls | grep $db_name" ""

assert_end "_ls(), _create() and _drop()"
