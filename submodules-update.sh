#!/bin/bash

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"

(
cd "$THIS_DIR"
set -x
git submodule foreach git pull origin master
)
