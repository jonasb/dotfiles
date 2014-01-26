#!/bin/bash
set -e -u

THIS_DIR="$(pushd "$(dirname "$0")" > /dev/null; pwd; popd > /dev/null)"

function info() {
  echo "$1"
}

function warn() {
  echo -e "\x1B[31m$1\x1B[0m"
}

function link_files() {
  local source="$1"
  local target="$2"
  local prefix="$3"

  for file in "$source"/*; do
    [ "$(basename "$file")" = "dot" ] && continue
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
      info "Skipping $source_file (already linked)"
    else
      warn "Skipping $source_file (already symlinked to $symlink)"
    fi
  elif [ -e "$target_file" ]; then
    warn "Skipping $source_file (target file exists $target_file)"
  else
    info "Linking $source_file -> $target_file"
    ln -s "$source_file" "$target_file"
  fi
}

info "Update source"
(
cd "$THIS_DIR"
git submodule update --init --recursive
)

info "Link files"
link_files "$THIS_DIR/home/dot" ~ .
link_files "$THIS_DIR/home" ~ ''
link_files "$THIS_DIR/config" ~/.config ''

info "Update vim docs"
vim -e -s <<-EOF
:Helptags
:quit
EOF
