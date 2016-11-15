#!/bin/bash
# shellcheck disable=1091
source "./tests/test-helper.sh"

# FIXME
# assert_raises "_cp " 1
# assert_raises "_cp one-param" 1

origin="$(_create-test-db-name)"
drop() {
  pg drop "$origin"
}
trap drop EXIT

pg create "$origin"
psql "$origin" <<EOF
create table test(
  name varchar(20)
);
insert into test(name) values('random name');
EOF
assert \
  "pg dump-table $origin test | grep -i insert" \
  "INSERT INTO test (name) VALUES ('random name');"

assert_end "_dump-table()"

