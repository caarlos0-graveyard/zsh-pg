#!/bin/bash
set -eo pipefail
# shellcheck disable=SC1091
source ./build/build.sh
echo -e "\nRunning tests..."
find ./tests -name '*-test.sh' | while read -r test; do
  bash "$test"
done
