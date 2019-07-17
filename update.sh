#!/bin/bash
set -e -u

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"

(
cd "$THIS_DIR"
echo "Update source"
set -x
git pull --rebase --autostash
git submodule sync
git submodule update --init --recursive

./dotfiles.sh
)
