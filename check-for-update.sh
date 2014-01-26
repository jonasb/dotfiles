#!/bin/bash
set -e -u

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"
LAST_UPDATE_FILE="$THIS_DIR/.last-update"
epoch_target=7

function current_epoch_days() {
  echo $(($(date +%s) / 60 / 60 / 24))
}

function update_last_update_file() {
  echo "LAST_EPOCH=$(current_epoch_days)" > "$LAST_UPDATE_FILE"
}

function update() {
  "$THIS_DIR/update.sh"
  update_last_update_file
}

[ -f "$LAST_UPDATE_FILE" ] && source "$LAST_UPDATE_FILE"
[ -z "${LAST_EPOCH+x}" ] && update_last_update_file && exit 0

epoch_diff=$(($(current_epoch_days) - $LAST_EPOCH))
if [ $epoch_diff -gt $epoch_target ]; then
  update
fi
