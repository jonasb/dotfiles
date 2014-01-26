#!/bin/bash
# executes dexdump on .dex file zipped in .jar file
set -e
DEX_JAR="$1"
JAR=jar
DEXDUMP=dexdump

TARGET_FILE="${DEX_JAR}.txt"
TMP_DIR="$(mktemp -d -t dexfile)"
TMP_JAR="$TMP_DIR/dexfile.jar"
cp "$DEX_JAR" "$TMP_JAR"
(
  cd "$TMP_DIR"
  $JAR xf dexfile.jar
)

find "$TMP_DIR" -name '*.dex' -exec "$DEXDUMP" {} \; > "$TARGET_FILE"
echo "dexdumped to $TARGET_FILE"

rm -rf "$TMP_DIR"
