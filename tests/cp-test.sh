#!/bin/bash
source "./tests/test-helper.sh"

# FIXME
# assert_raises "_cp " 1
# assert_raises "_cp one-param" 1

origin="$(_create-test-db-name)"
sleep 1
target="$(_create-test-db-name)"
assert "_ls | grep $origin" ""
assert "_ls | grep $target" ""
_create "$origin"
_cp "$origin" "$target"
assert "_ls | grep $origin" "$origin"
assert "_ls | grep $target" "$target"
_drop "$origin"
_drop "$target"

assert_end "_cp()"
