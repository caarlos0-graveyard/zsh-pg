#!/bin/bash
source "./tests/test-helper.sh"

# FIXME
# assert_raises "pg mv " 1
# assert_raises "pg mv one-param" 1

origin="$(_create-test-db-name)"
sleep 1
target="$(_create-test-db-name)"
assert "pg ls | grep $origin" ""
pg create "$origin"
assert "pg ls | grep $target" ""
assert "pg ls | grep $origin" "$origin"
pg mv "$origin" "$target"
assert "pg ls | grep $origin" ""
assert "pg ls | grep $target" "$target"
pg drop "$target"

assert_end "_mv()"
