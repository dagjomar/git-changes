#!/bin/bash

# Git Diff Helper - Shows you information about changes between two commits
# -------------------------------------------------------------------------
# A developer utility script that helps find and show changes done between
# two commits in the git repo in order to help understand what would potentially
# be put into production, etc.
#
# Example outputs:
# - A list of all commit messages
# - A list of all files touched/changed
#
# Optional inputs:
# - Directory to limit the search to
#
# Example usage:
#   ./gitdiff.sh abcdef...fedcba
#   ./gitdiff.sh abcdef
#   ./gitdiff.sh abcdef fedcba
#   ./gitdiff.sh abcdef fedcba ./frontend
# -------------------------------------------------------------------------

# Validate input arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <from> [to] [directory]"
    exit 1
fi

# Assign arguments and handle the "from...to" shorthand
if [[ "$1" == *"..."* ]]; then
    IFS="..." read -r commit1 commit2 <<< "$1"
else
    commit1=$1
    commit2=${2:-HEAD} # Default to HEAD if "to" is not provided
    directory=${3:-}   # Optional directory
fi

# Display header
echo "Changes between hash $commit1 -----> $commit2"

# Show commit messages
echo
echo
echo "List of commits:"
git --no-pager log --oneline "$commit1...$commit2" --pretty=format:'%C(red)%h%C(reset) - %C(green)(%ar)%C(reset) %C(auto)%s - %C(bold blue)%an %C(auto)%d'

# Show changed files
echo
echo
echo
echo "List of files changed:"
if [ -n "$directory" ]; then
    git --no-pager diff --name-only "$commit1...$commit2" "$directory"
else
    git --no-pager diff --name-only "$commit1...$commit2"
fi
echo
