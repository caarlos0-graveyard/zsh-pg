#!/bin/bash
source "./tests/test-helper.sh"

# FIXME
# assert_raises "_mv " 1
# assert_raises "_mv one-param" 1

origin="$(_create-test-db-name)"
sleep 1
target="$(_create-test-db-name)"
assert "_ls | grep $origin" ""
_create "$origin"
assert "_ls | grep $target" ""
assert "_ls | grep $origin" "$origin"
_mv "$origin" "$target"
assert "_ls | grep $origin" ""
assert "_ls | grep $target" "$target"
_drop "$target"

assert_end "_mv()"
