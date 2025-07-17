#!/bin/bash

# Installation script for todo-txt-helpers

set -e

# Default installation directory
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Check if we have write permissions to the install directory
if [ ! -w "$INSTALL_DIR" ]; then
    echo "Error: Cannot write to $INSTALL_DIR"
    echo "Try running with sudo or set INSTALL_DIR to a writable location:"
    echo "  INSTALL_DIR=~/.local/bin ./install.sh"
    exit 1
fi

# Copy the script
echo "Installing todo-txt-helpers to $INSTALL_DIR"
cp todo-txt-helpers "$INSTALL_DIR/todo-txt-helpers"

# Make sure it's executable
chmod +x "$INSTALL_DIR/todo-txt-helpers"

echo "Installation complete!"
echo ""
echo "Make sure $INSTALL_DIR is in your PATH, then you can use:"
echo "  todo-txt-helpers help"
echo ""
echo "Don't forget to set the required environment variables:"
echo "  export TODO_FILE=~/todo.txt"
echo "  export TODO_DONE_FILE=~/done.txt"
echo "  export TODO_RECUR_FILE=~/recur.txt  # optional"
