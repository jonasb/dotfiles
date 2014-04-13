#!/bin/bash
set -e -u

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"
LAST_UPDATE_FILE="$THIS_DIR/.last-update"
LOCK_FILE="$THIS_DIR/.update.lock"
EPOCH_TARGET=3

function current_epoch_days() {
  echo $(($(date +%s) / 60 / 60 / 24))
}

function update_last_update_file() {
  echo "LAST_EPOCH=$(current_epoch_days)" > "$LAST_UPDATE_FILE"
}

function update() {
  TMP_LOCK_FILE="$(mktemp -t lock-file-XXXX)"
  set +e
  cp -n "$TMP_LOCK_FILE" "$LOCK_FILE"
  [ "$?" != '0' ] && echo "Update in progress, abort" && exit 0
  set -e
  success=true
  "$THIS_DIR/update.sh" || success=false
  rm "$LOCK_FILE"
  [ $success == true ] && update_last_update_file
}

[ -f "$LAST_UPDATE_FILE" ] && source "$LAST_UPDATE_FILE"
# abort if LAST_UPDATE_FILE doesn't exist or doesn't contain LAST_EPOCH
[ -z "${LAST_EPOCH+x}" ] && update_last_update_file && exit 0

EPOCH_DIFF=$(($(current_epoch_days) - $LAST_EPOCH))
if [ $EPOCH_DIFF -gt $EPOCH_TARGET ]; then
  update
fi
