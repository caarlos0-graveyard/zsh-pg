#!/bin/zsh

__pg-check() {
  if [ -z "$2" ]; then
    echo "Usage: pg $1 <db_name>"
    return 0
  fi
}

__pg-check2() {
  if [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: pg $1 <origin> <target>"
    return 0
  fi
}

_pg-ls() {
  psql postgres -Atq -c "select d.datname from pg_catalog.pg_database d;"
}

_pg-kill-connections() {
  local db_name="$*"
  __pg-check "kill-connections" "$db_name"
  psql postgres > /dev/null <<EOF
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    AND datname='$db_name';
EOF
}

_pg-create() {
  local db_name="$*"
  __pg-check "create" "$db_name"
  createdb "$db_name"
}

_pg-drop() {
  local db_name="$*"
  __pg-check "drop" "$db_name"
  _pg-kill-connections "$db_name"
  dropdb --if-exists "$db_name"
}

_pg-cp() {
  local origin="$1"
  local target="$2"
  __pg-check2 "cp" "$origin" "$target"
  _pg-kill-connections "$origin"
  psql postgres &> /dev/null <<EOF
    CREATE DATABASE "$target" WITH TEMPLATE "$origin";
EOF
}

_pg-mv() {
  local origin="$1"
  local target="$2"
  __pg-check2 "mv" "$origin" "$target"
  _pg-kill-connections "$origin"
  psql postgres &> /dev/null <<EOF
    ALTER DATABASE "$origin" RENAME TO "$target";
EOF
}

pg() {
  local command="$1"; shift
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
    *)
      echo "Usage: pg (ls|kill-connections|create|drop|cp|mv) <args>"
      return 0
      ;;
  esac
}

