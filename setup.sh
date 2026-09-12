#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"     # cd to source directory

cd "./.config/"
stow -v -t ~/.config .		# create symlinks using stow
cd "../"

PROJECT_DIR="khal-helper"          # subfolder containing Cargo.toml
BINARY_NAME="khal-helper"          # must match the [package] name in Cargo.toml
DEST_DIR="$HOME/.config/nicerice/bin"        # where the built binary should end up

echo "Building $BINARY_NAME in $PROJECT_DIR..."
(cd "$PROJECT_DIR" && cargo build --release)

mkdir -p "$DEST_DIR"

SRC_PATH="$PROJECT_DIR/target/release/$BINARY_NAME"

if [ ! -f "$SRC_PATH" ]; then
    echo "Error: built binary not found at $SRC_PATH" >&2
    exit 1
fi

mv "$SRC_PATH" "$DEST_DIR/$BINARY_NAME"
echo "Installed $BINARY_NAME to $DEST_DIR/$BINARY_NAME"
