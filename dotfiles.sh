#!/bin/bash
set -e -u

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"

function link_files() {
  local source="$1"
  local target="$2"
  local prefix="$3"

  for file in "$source"/*; do
    link_file "$file" "$target" "$prefix"
  done
}

function link_file() {
  local source_file="$1"
  local target_dir="$2"
  local prefix="$3"
  local target_file="$target_dir/$prefix$(basename "$source_file")"
  if [ -h "$target_file" ]; then
    local symlink="$(readlink "$target_file")"
    if [ "$source_file" = "$symlink" ]; then
      echo "Skipping $source_file (already linked)"
    else
      echo "Skipping $source_file (already symlinked to $symlink)"
    fi
  elif [ -e "$target_file" ]; then
    echo "Skipping $source_file (target file exists $target_file)"
  else
    echo "Linking $source_file -> $target_file"
    ln -s "$source_file" "$target_file"
  fi
}

echo "Update source"
(
cd "$THIS_DIR"
git submodule update --init --recursive
)

echo "Link files"
link_files "$THIS_DIR/home/dot" ~ .

echo "Update vim docs"
vim -e -s <<-EOF
:Helptags
:quit
EOF
