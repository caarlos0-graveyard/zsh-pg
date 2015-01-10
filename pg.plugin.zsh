#!/bin/zsh
set -eo pipefail

__check() {
  if [ -z "$2" ]; then
    echo "Usage: pg $1 <db_name>"
    exit 1
  fi
}

__check2() {
  if [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: pg $1 <origin> <target>"
    exit 1
  fi
}

_ls() {
  psql postgres -Atq -c "select d.datname from pg_catalog.pg_database d;"
}

_kill-connections() {
  local db_name="$*"
  __check "kill-connections" "$db_name"
  psql postgres > /dev/null <<EOF
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    AND datname='$db_name';
EOF
}

_create() {
  local db_name="$*"
  __check "create" "$db_name"
  createdb "$db_name"
}

_drop() {
  local db_name="$*"
  __check "drop" "$db_name"
  _kill-connections "$db_name"
  dropdb --if-exists "$db_name"
}

_cp() {
  local origin="$1"
  local target="$2"
  __check2 "cp" "$origin" "$target"
  _kill-connections "$origin"
  psql postgres &> /dev/null <<EOF
    CREATE DATABASE "$target" WITH TEMPLATE "$origin";
EOF
}

_mv() {
  local origin="$1"
  local target="$2"
  __check2 "mv" "$origin" "$target"
  _kill-connections "$origin"
  psql postgres &> /dev/null <<EOF
    ALTER DATABASE "$origin" RENAME TO "$target";
EOF
}

pg() {
  local command="$1"; shift
  case "$command" in
    ls)
      _ls "$*"
      ;;
    kill-connections)
      _kill-connections "$*"
      ;;
    create)
      _create "$*"
      ;;
    drop)
      _drop "$*"
      ;;
    cp)
      _cp "$*"
      ;;
    mv)
      _mv "$*"
      ;;
    *)
      echo "Usage: pg (ls|kill-connections|create|drop|cp|mv) <args>"
      ;;
  esac
}

