#!/bin/bash
# shellcheck disable=SC1091
source "./tests/test-helper.sh"

# FIXME
# assert_raises "_cp " 1
# assert_raises "_cp one-param" 1

origin="$(_create-test-db-name)"
sleep 1
target="$(_create-test-db-name)"
drop() {
  pg drop "$origin"
  pg drop "$target"
}
trap drop EXIT

assert "pg ls | grep $origin" ""
assert "pg ls | grep $target" ""
pg create "$origin"
pg cp "$origin" "$target"
assert "pg ls | grep $origin" "$origin"
assert "pg ls | grep $target" "$target"
pg drop "$origin"
pg drop "$target"

assert_end "_cp()"
