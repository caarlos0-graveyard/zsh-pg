#!/bin/sh
#
# shellcheck disable=SC2039
__pg-check() {
  if [ "$#" != 2 ]; then
    echo "Usage: pg $1 <db_name>"
    return 1
  fi
}

# shellcheck disable=SC2039
__pg-check2() {
  if [ "$#" != 3 ]; then
    echo "Usage: pg $1 <origin> <target>"
    return 1
  fi
}

# shellcheck disable=SC2039
_pg-ls() {
  psql postgres -Atq -c "select d.datname from pg_catalog.pg_database d;"
}

# shellcheck disable=SC2039
_pg-kill-connections() {
  # shellcheck disable=SC2039
  local db_name="$*"
  if __pg-check "kill-connections" "$db_name"; then
    psql postgres > /dev/null <<EOF
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    AND datname='$db_name';
EOF
  fi
}

# shellcheck disable=SC2039
_pg-create() {
  # shellcheck disable=SC2039
  local db_name="$*"
  __pg-check "create" "$db_name" && \
    createdb "$db_name"
}

# shellcheck disable=SC2039
_pg-drop() {
  # shellcheck disable=SC2039
  local db_name="$*"
  if __pg-check "drop" "$db_name"; then
    _pg-kill-connections "$db_name"
    dropdb --if-exists "$db_name"
  fi
}

# shellcheck disable=SC2039
_pg-cp() {
  # shellcheck disable=SC2039
  local origin target
  origin="$1"
  target="$2"
  if __pg-check2 "cp" "$origin" "$target"; then
    _pg-kill-connections "$origin"
    psql postgres > /dev/null <<EOF
      CREATE DATABASE "$target" WITH TEMPLATE "$origin";
EOF
  fi
}

# shellcheck disable=SC2039
_pg-mv() {
  # shellcheck disable=SC2039
  local origin target
  origin="$1"
  target="$2"
  if __pg-check2 "mv" "$origin" "$target"; then
    _pg-kill-connections "$origin"
    psql postgres > /dev/null <<EOF
      ALTER DATABASE "$origin" RENAME TO "$target";
EOF
  fi
}

# shellcheck disable=SC2039
_pg-dump-table() {
  # shellcheck disable=SC2039
  local db_name table_name
  db_name="$1"
  table_name="$2"
  if [ "$#" != 2 ]; then
    echo "Usage: pg dump-table <db_name> <table_name>"
  else
    pg_dump --table="$table_name" --data-only --column-inserts "$db_name"
  fi
}

pg() {
  # shellcheck disable=SC2039
  local command
  if [ "$#" != 0 ]; then
    command="$1"; shift
  fi
  case "$command" in
    ls)
      _pg-ls "$@"
      ;;
    kill-connections)
      _pg-kill-connections "$@"
      ;;
    create)
      _pg-create "$@"
      ;;
    drop)
      _pg-drop "$@"
      ;;
    cp)
      _pg-cp "$@"
      ;;
    mv)
      _pg-mv "$@"
      ;;
    dump-table)
      _pg-dump-table "$@"
      ;;
    *)
      echo "Usage: pg (ls|kill-connections|create|drop|cp|mv|dump-table) <args>"
      return 0
      ;;
  esac
}
