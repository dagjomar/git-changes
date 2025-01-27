#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHANGES_SCRIPT="$SCRIPT_DIR/git-changes.sh"

# Make the git-changes script executable
chmod +x "$CHANGES_SCRIPT"

# Create the git alias using the absolute path
git config --global alias.changes "!bash $CHANGES_SCRIPT"

echo "✅ Git alias 'changes' installed successfully!"
echo "You can now use 'git changes' from any directory"
echo
echo "Examples:"
echo "  git changes"
echo "  git changes abc123 def456"
echo "  git changes abc123"
echo "  git changes abc123 def456 ./src" 