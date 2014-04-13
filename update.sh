#!/bin/bash
set -e -u

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"

(
cd "$THIS_DIR"
echo "Update source"
set -x
git pull
git submodule sync
git submodule update --init --recursive

./dotfiles.sh
)
