#!/bin/sh

__pg_check() {
  if [ "$#" != 2 ]; then
    echo "Usage: pg $1 <db_name>"
    return 1
  fi
}

__pg_check2() {
  if [ "$#" != 3 ]; then
    echo "Usage: pg $1 <origin> <target>"
    return 1
  fi
}

_pg_ls() {
  psql postgres -Atq -c "select d.datname from pg_catalog.pg_database d;"
}

_pg_kill_connections() {
  if __pg_check "kill-connections" "$*"; then
    psql postgres > /dev/null <<EOF
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    AND datname='$db_name';
EOF
  fi
}

_pg_create() {
  # shellcheck disable=SC2039
  local db_name="$*"
  __pg_check "create" "$db_name" && \
    createdb "$db_name"
}

_pg_drop() {
  # shellcheck disable=SC2039
  local db_name="$*"
  if __pg_check "drop" "$db_name"; then
    _pg_kill_connections "$db_name"
    dropdb --if-exists "$db_name"
  fi
}

_pg_cp() {
  # shellcheck disable=SC2039
  local origin="$1" target="$2"
  if __pg_check2 "cp" "$origin" "$target"; then
    _pg_kill_connections "$origin"
    psql postgres > /dev/null <<EOF
      CREATE DATABASE "$target" WITH TEMPLATE "$origin";
EOF
  fi
}

_pg_mv() {
  # shellcheck disable=SC2039
  local origin="$1" target="$2"
  if __pg_check2 "mv" "$origin" "$target"; then
    _pg_kill_connections "$origin"
    psql postgres > /dev/null <<EOF
      ALTER DATABASE "$origin" RENAME TO "$target";
EOF
  fi
}

_pg_dump_table() {
  # shellcheck disable=SC2039
  local db_name="$1" table_name="$2"
  if [ "$#" != 2 ]; then
    echo "Usage: pg dump-table <db_name> <table_name>"
  else
    pg_dump --table="$table_name" --data-only --column-inserts "$db_name"
  fi
}

pg() {
  if [ "$#" != 0 ]; then
    # shellcheck disable=SC2039
    local command="$1"; shift
  fi
  case "$command" in
    ls)
      _pg_ls "$@"
      ;;
    kill-connections)
      _pg_kill_connections "$@"
      ;;
    create)
      _pg_create "$@"
      ;;
    drop)
      _pg_drop "$@"
      ;;
    cp)
      _pg_cp "$@"
      ;;
    mv)
      _pg_mv "$@"
      ;;
    dump-table)
      _pg_dump_table "$@"
      ;;
    *)
      echo "Usage: pg (ls|kill-connections|create|drop|cp|mv|dump-table) <args>"
      return 0
      ;;
  esac
}
