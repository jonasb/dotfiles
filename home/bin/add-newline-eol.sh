#!/bin/bash

set -e
FIND_PATH="${1}"
[ -z "$FIND_PATH" ] && FIND_PATH='.'

set -u
FIND=gfind
SED=gsed

set -x
"$FIND" "$FIND_PATH" \( \
    -name '*.xml' \
    -o -name '*.java' \
    -o -name '*.sh' \
    -o -name '*.h' \
    -o -name '*.cpp' \
    \) -exec "$SED" -i -e '$a\' {} \;
