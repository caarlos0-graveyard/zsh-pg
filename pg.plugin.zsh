#!/bin/sh

__pg-check() {
  if [ "$#" != 2 ]; then
    echo "Usage: pg $1 <db_name>"
    return 1
  fi
}

__pg-check2() {
  if [ "$#" != 3 ]; then
    echo "Usage: pg $1 <origin> <target>"
    return 1
  fi
}

_pg-ls() {
  psql postgres -Atq -c "select d.datname from pg_catalog.pg_database d;"
}

_pg-kill-connections() {
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

_pg-create() {
  local db_name="$*"
  __pg-check "create" "$db_name" && \
    createdb "$db_name"
}

_pg-drop() {
  local db_name="$*"
  if __pg-check "drop" "$db_name"; then
    _pg-kill-connections "$db_name"
    dropdb --if-exists "$db_name"
  fi
}

_pg-cp() {
  local origin="$1"
  local target="$2"
  if __pg-check2 "cp" "$origin" "$target"; then
    _pg-kill-connections "$origin"
    psql postgres > /dev/null <<EOF
      CREATE DATABASE "$target" WITH TEMPLATE "$origin";
EOF
  fi
}

_pg-mv() {
  local origin="$1"
  local target="$2"
  if __pg-check2 "mv" "$origin" "$target"; then
    _pg-kill-connections "$origin"
    psql postgres > /dev/null <<EOF
      ALTER DATABASE "$origin" RENAME TO "$target";
EOF
  fi
}

_pg-dump-table() {
  local db_name="$1"
  local table_name="$2"
  if [ "$#" != 2 ]; then
    echo "Usage: pg dump-table <db_name> <table_name>"
  else
    pg_dump --table="$table_name" --data-only --column-inserts "$db_name"
  fi
}

pg() {
  if [ "$#" != 0 ]; then
    local command="$1"; shift
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
