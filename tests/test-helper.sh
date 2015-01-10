#!/bin/bash
[[ ! -f "assert.sh" ]] && \
  wget https://raw.githubusercontent.com/lehmannro/assert.sh/master/assert.sh \
  &> /dev/null
source ./assert.sh
source ./pg.plugin.zsh

_create-test-db-name() {
  if [ -f /usr/local/bin/gmd5sum ]; then
    date | gmd5sum
  else
    date | md5sum
  fi
}
